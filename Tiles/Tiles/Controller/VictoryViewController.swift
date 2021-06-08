//
//  VictoryViewController.swift
//  Tiles
//
//  Created by Norberto Taveras on 6/8/21.
//

import UIKit
import CoreData

class VictoryViewController: UIViewController {

    @IBOutlet var leaderboardButton: UIButton!
    @IBOutlet var gameDuration: UILabel!
    @IBOutlet var numOfMoves: UILabel!
    
    // variables that hold the data passed forward
    // from the previous view controller
    public var playerName: String = ""
    public var moves: Int = 0
    public var movesText: String = ""
    public var durationText: String = ""
    public var duration: Int = 0
    public var madeLeaderboard: Bool = false
    
    // timer to determine the duration of the pulsate effect
    var pulsateLeaderboard: Timer?
    var pulsatePhase: Bool = false
    
    // variable to keep track the index iteration
    // of our leaderboard
    var leaderboardIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new leader based on the properties
        // of their name, duration, moves and date
        let newLeader = Leader(
            name: playerName,
            time: duration,
            moves: moves,
            date: Date())
        
        // load the leaderboard data into an array of leaders
        var leaders = Leader.loadLeaderboard()
        
        // insert a new leader at a specific index within
        // our leaderboard
        leaderboardIndex = Leader.insertLeader(leaders: &leaders, newLeader: newLeader)
        
        // checks if the leaderboard index is not equal to nil
        // then the leaderboard is saved and indicated
        // to let the user know that they have made it into the leaderboard
        if leaderboardIndex != nil {
            Leader.saveLeaderboard(leaders: leaders)
            indicateLeaderboard()
        }
    }
    
    // method to indicate when the user has made it
    // into the leaderboard
    public func indicateLeaderboard() {
        pulsateLeaderboard = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(1), repeats: true,
            block: { (timer) in
            DispatchQueue.main.async {
                self.pulsateTick()
            }
        })
    }
    
    // method that somewhat implements a fake pulsating
    // effect my changing the the leaderboard button title label
    // colors
    public func pulsateTick() {
        pulsatePhase = !pulsatePhase
        leaderboardButton.titleLabel?.textColor = pulsatePhase
            ? UIColor.white
            : UIColor.init(
                displayP3Red: 239.0/255.0,
                green: 154.0/255.0,
                blue: 85.0/255.0,
                alpha: 1.0)
    }
    
    // override method of view will appear
    // we are updating the moves and game duration label
    // with the information passed in from the previous view controller
    override func viewWillAppear(_ animated: Bool) {
        numOfMoves.text = moves.description
        gameDuration.text = durationText
    }
    
    // override of prepare segue - which will help
    // to pass the highligheted row into the next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "victory_leaderboard":
            if let destination = segue.destination as? LeaderboardViewController {
                destination.highlightRow = leaderboardIndex
            }
        default:
            break
        }
    }
    
    
}
