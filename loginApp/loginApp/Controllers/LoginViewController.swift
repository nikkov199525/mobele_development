//
//  LoginViewController.swift
//  loginApp
//
//  Created by Дмитрий Васильев on 11.11.2025.
//

import UIKit

// MARK: - Login View Controller
/// Контроллер экрана авторизации
class LoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgetLoginButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!

    // MARK: - Properties
    private let mockUser = User.mockUser()
    private var user: String { mockUser.login }
    private var pass: String { mockUser.password }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearTextFields()
    }

    // MARK: - Setup
    private func setupBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "back")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    private func clearTextFields() {
        loginTextField.text = ""
        passwordTextField.text = ""
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let productsVC = navController.topViewController as? ProductsViewController {
            productsVC.userName = mockUser.name
        } else if let productsVC = segue.destination as? ProductsViewController {
            productsVC.userName = mockUser.name
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard loginTextField.text == user, passwordTextField.text == pass else {
            showAlert(title: "Ошибка", message: "Неверный логин или пароль") {
                self.passwordTextField.text = ""
            }
            return false
        }
        return true
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    // MARK: - IBActions
    @IBAction func loginButtonForgetTapped() {
        showAlert(title: "Ваш логин", message: "Логин: \(user)")
    }

    @IBAction func passwordForgetButtonTapped() {
        showAlert(title: "Ваш пароль", message: "Пароль: \(pass)")
    }

    // MARK: - Helper Methods
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Лады", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
}
