//
//  ViewController.swift
//  Tiles
//
//  Created by Norberto Taveras on 6/8/21.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    @IBOutlet var gameDifficulty: UISegmentedControl!
    @IBOutlet var playerName: UITextField!
    
    var difficulty: Difficulty = .normal
    
    public enum Difficulty: Int {
        case easy = 0
        case normal = 1
        case hard = 2
        case count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameDifficulty.selectedSegmentIndex = difficulty.rawValue
        playerName.text = "Player 1"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerName.resignFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "gameView":
            if let destination = segue.destination as? GameFieldViewController {
                destination.difficulty = difficulty
                destination.playerName = playerName.text ?? "Player 1"
            }
            
        default:
            break
        }
    }
    
    @IBAction func gameDifficultyChanged(_ sender: UISegmentedControl) {
        // optional bind a new game difficulty based on the selected
        // segment index, then assign the difficulty variable
        // to the newly selected difficulty
        if let newDifficulty = Difficulty.init(
            rawValue: sender.selectedSegmentIndex) {
            difficulty = newDifficulty
        }
    }
    
    @IBAction func play(_ sender: Any) {
    }
}

