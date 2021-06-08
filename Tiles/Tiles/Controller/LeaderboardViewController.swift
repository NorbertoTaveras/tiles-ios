//
//  LeaderboardViewController.swift
//  Tiles
//
//  Created by Norberto Taveras on 6/8/21.
//

import UIKit
import CoreData

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // empty array of leaders
    var leaders: [Leader] = []
    
    // variable to keep track of the row
    // to be highlighted in the tableview
    var highlightRow: Int?
    
    @IBOutlet var leaderboardTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // load the leaderboard into our array fo leaders
        leaders = Leader.loadLeaderboard()
        
        // refresh the leaderbaord table view
        leaderboardTableView.reloadData()
    }
    
    // MARK: Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "leader_cell",
            for: indexPath) as! LeaderboardTableViewCell

        let leader = leaders[indexPath.row]
        
        cell.setupLeaderboardCell(
            name: leader.name,
            time: leader.time,
            moves: leader.moves,
            date: leader.date,
            highlight: indexPath.row == highlightRow)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
