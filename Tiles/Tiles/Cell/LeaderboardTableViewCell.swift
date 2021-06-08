//
//  LeaderboardTableViewCell.swift
//  Tiles
//
//  Created by Norberto Taveras on 6/8/21.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var moves: UILabel!
    @IBOutlet var date: UILabel!
    
    // constant that holds the win color
    let winColor = UIColor.init(
        displayP3Red: 255/255.0,
        green: 181/255.0,
        blue: 145/255.0,
        alpha: 1.0)
    
    // constant that holds a normal color of white
    let normalColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // method to set up the leaderbord cell
    func setupLeaderboardCell(name: String, time: Int, moves: Int,
                              date: Date, highlight: Bool ) {
        
        // constant of a date formatter to format the date
        // of the memory game
        let dateFormatter = DateFormatter()
        
        // formating the date as year-month-day
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // converting the date into a string
        let stringDate = dateFormatter.string(from: date)

        // retrieving the time between a starting date and ending date
        // to be turned into a string
        let timeString = GameFieldViewController.timeStringBetween(
            startDate: Date(timeIntervalSince1970: 0),
            endDate: Date(timeIntervalSince1970: Double(time)))

        // setting the components of cell
        // to include the name, time, moves and data
        // to be displayed in the leaderboard
        self.name.text = "Name: \(name)"
        self.time.text = "Time: \(timeString.text)"
        self.moves.text = "Moves: \(moves.description)"
        self.date.text = "Date: \(stringDate)"
        backgroundColor = highlight ? winColor : normalColor
    }
}
