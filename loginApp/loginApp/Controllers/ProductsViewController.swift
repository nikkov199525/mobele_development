//
//  ProductsViewController.swift
//  loginApp
//
//  Created by Дмитрий Васильев on 12.11.2025.
//

import UIKit

// MARK: - Products View Controller
/// Контроллер экрана с товарами
class ProductsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var logOutButton: UIButton!

    // MARK: - Properties
    var userName: String?
    private var allProducts: [GoodsModel] = []
    private var products: [GoodsModel] = []

    private let productsService: ProductsServicing = ProductsService()
    private let searchEngine = NGramSearch(mode: .trigram)

    private let searchController = UISearchController(searchResultsController: nil)
    private var refreshControl = UIRefreshControl()
    private var loadingIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadProducts()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "Товары"

        setupSearch()
        setupLoadingIndicator()

        if tableView != nil {
            setupTableView()
        } else {
            setupTableViewProgrammatically()
        }
    }

    private func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder =  "Поиск"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
    }

    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "GoodsCell")
        tableView?.rowHeight = 80

        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }

    private func setupTableViewProgrammatically() {
        let table = UITableView(frame: view.bounds, style: .plain)
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "GoodsCell")
        table.rowHeight = 80

        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        table.refreshControl = refreshControl

        view.insertSubview(table, at: 0)
        tableView = table
    }

    // MARK: - Data Loading
    private func loadProducts() {
        setLoading(true)
        productsService.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.setLoading(false)

                switch result {
                case .success(let items):
                    self.allProducts = items
                    self.applySearch(query: self.searchController.searchBar.text)
                case .failure(let error):
                    self.allProducts = GoodsModel.mockGoods()
                    self.applySearch(query: self.searchController.searchBar.text)
                    self.showNetworkError(error)
                }
            }
        }
    }

    @objc private func refreshTriggered() {
        productsService.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.refreshControl.endRefreshing()

                switch result {
                case .success(let items):
                    self.allProducts = items
                    self.applySearch(query: self.searchController.searchBar.text)
                case .failure(let error):
                    self.showNetworkError(error)
                }
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }

    private func applySearch(query: String?) {
        let q = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            products = allProducts
        } else {
            products = searchEngine.filter(query: q, items: allProducts)
        }
        tableView?.reloadData()
    }

    private func showNetworkError(_ error: NetworkError) {
        let alert = UIAlertController(
            title: "Проблема с загрузкой",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadProducts()
        })
        present(alert, animated: true)
    }

    // MARK: - IBActions
    @IBAction func logOutButtonTapped() {
        // Handled by segue
    }

    @IBAction func unwindToProductsViewController(segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCart" {
            // Cart segue - handled automatically
        }
    }
}

// MARK: - UITableViewDataSource
extension ProductsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsCell", for: indexPath)
        let product = products[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = product.title
        content.secondaryText = String(format: "%.2f ₽", product.price)
        content.image = UIImage(systemName: "photo")
        content.imageProperties.cornerRadius = 8
        content.imageProperties.maximumSize = CGSize(width: 44, height: 44)

        cell.contentConfiguration = content
        cell.accessoryType = .detailButton

        // Асинхронная загрузка изображения (если URL)
        let currentRow = indexPath.row
        ImageLoader.shared.loadImage(from: product.image) { [weak self, weak tableView] image in
            DispatchQueue.main.async {
                guard let self, let tableView else { return }
                guard currentRow < self.products.count else { return }
                guard self.products[currentRow].id == product.id else { return }
                guard let visibleCell = tableView.cellForRow(at: IndexPath(row: currentRow, section: indexPath.section)) else { return }

                var updated = visibleCell.defaultContentConfiguration()
                updated.text = product.title
                updated.secondaryText = String(format: "%.2f ₽", product.price)
                updated.image = image ?? UIImage(systemName: "photo")
                updated.imageProperties.cornerRadius = 8
                updated.imageProperties.maximumSize = CGSize(width: 44, height: 44)
                visibleCell.contentConfiguration = updated
            }
        }

        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension ProductsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applySearch(query: searchController.searchBar.text)
    }
}

// MARK: - UITableViewDelegate
extension ProductsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedProduct = products[indexPath.row]
        CartManager.shared.addToCart(selectedProduct)

        showAddedToCartAlert(for: selectedProduct)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let product = products[indexPath.row]
        showProductDetails(product)
    }

    // MARK: - Helper Methods
    private func showAddedToCartAlert(for product: GoodsModel) {
        let alert = UIAlertController(
            title: "Добавлено в корзину",
            message: "\(product.title) добавлен в корзину",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showProductDetails(_ product: GoodsModel) {
        let alert = UIAlertController(
            title: product.title,
            message: product.description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Закрыть", style: .default))
        present(alert, animated: true)
    }
}
