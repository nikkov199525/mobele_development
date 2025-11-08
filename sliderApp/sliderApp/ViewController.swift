//
//  ViewController.swift
//  sliderApp
//
//  Created by Дмитрий Васильев on 07.11.2025.
//

import UIKit

final class ViewController: UIViewController {
    @IBOutlet weak var informLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var startButton: UIButton!
    
    private var score: Int = 0
    private var round: Int = 0
    private var isGaming = false
    private var targetValue: Int = 0
    private var roundPassed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        startButton.setTitle("Start", for: .normal)
        setupUI()
    }

    private func setupUI() {
       isGaming = false
        slider.isEnabled = false
        startButton.setTitle("Start", for: .normal)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = Float(Int.random(in: 0...100))
        informLabel.text = "Угадай число"
        roundPassed = false
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Окей", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func startGame() {
        guard round < 3 else {
            endGame()
            return
        }
        round += 1
        roundPassed = false
        targetValue = Int.random(in: 0...100)
        informLabel.text = "Раунд \(round): попробуйте угадать число!"
    }

    private func endGame() {
        if isGaming && !roundPassed {
            let shtraff = Int(slider.value)
            score -= shtraff
            showAlert(title: "Game Over", message: "Ваш итоговый счет - \(score) очков.")
        }
 
        setupUI()
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        guard isGaming else { return }
        let currentValue = Int(sender.value)
        let difference = abs(targetValue - currentValue)

        switch difference {
        case 0:
            roundPassed = true
            score += targetValue
            informLabel.text = "Угадали! +\(targetValue) очков!"
        showAlert(title: "You win!", message: "Угадали! +\(targetValue) очков и того \(score) очков!")
                  if round == 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.endGame()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.startGame()
                }
            }

        case 1...2:
            informLabel.text = "Жарко!"
        case 3...5:
            informLabel.text = "Тепло"
        default:
            informLabel.text = "Холодно!"
        }
    }
    
    @IBAction func ManageGame(_ sender: UIButton) {
        if isGaming {
            endGame()
        } else {
            isGaming = true
            score = 0
            round = 0
            slider.isEnabled = true
            startButton.setTitle("Стоп", for: .normal)
            startGame()
        }
    }
}
