//
//  ViewController.swift
//  FirstApp
//
//  Created by Дмитрий Васильев on 31.10.2025.
//
import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var generalLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var clickButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
   var counter: Int = 0
    let radius: CGFloat = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        generalLabel.text = "Здравствуйте!"
        counterLabel.text = "0"
        counterLabel.textColor = .red
        clickButton.setTitle("Нажми на меня!", for: .normal)
        clickButton.layer.cornerRadius = radius
        clickButton.isHidden = false
        stopButton.setTitle("Стоп", for: .normal)
        stopButton.layer.cornerRadius = radius
        stopButton.isHidden = true
        counterLabel.accessibilityHint = "Всего кликов: \(counter)"
    }
    @IBAction func clickButton(_ sender: UIButton) {
        counter += 1
        counterLabel.text = "\(counter)"
        counterLabel.accessibilityHint = "Всего кликов: \(counter)"
        if stopButton.isHidden {
            stopButton.isHidden = false
        }
                if counter == 10 {
            alert(title: "You win!", message: "Поздравляем, Вы достигли своей цели")
                    clickButton.isHidden = true
                }
    }
    @IBAction func stopButon(_ sender: UIButton) {
         counter = 0
        counterLabel.text = "\(counter)"
        counterLabel.accessibilityHint = "Всего кликов: \(counter)"
        clickButton.isHidden = false
    }
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Окэу", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
