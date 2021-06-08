//
//  Leader.swift
//  Tiles
//
//  Created by Norberto Taveras on 6/8/21.
//

import Foundation
import CoreData
import UIKit

class Leader {
    
    // basic properties of player to be in
    // memory game leaderboard (name, time, moves, date)
    var name: String
    var time: Int
    var moves: Int
    var date: Date
    
    // constructor-initializer of a leader
    init(name: String, time: Int, moves: Int, date: Date) {
        self.name = name
        self.time = time
        self.moves = moves
        self.date = date
    }
    
    // method to sort the leaders by ascending time order completion
    // the keyword inout was used as a way to modify the passed in parameter, which in this case is an array of leaders (players
    // to be part of the leaderboard)
    private static func sortLeaders(leaders: inout [Leader]) {
        leaders.sort() {
            return $0.time < $1.time
        }
    }
    
    // method to insert a leader into the leaderboard-scoreboard
    // returns true if the Leader made it into the leaderboard-scoreboard
    public static func insertLeader(leaders: inout [Leader],
                                    newLeader: Leader) -> Int? {
        
        // append a new leader into the array of leaders
        leaders.append(newLeader)
        
        // sort the leaders once again, to acommodate the order
        // of the newly added in the leaderboard
        sortLeaders(leaders: &leaders)
        
        // in case that we have more leaders that it is expected
        // to be displayed in the leaderboard we remove the last one
        // in the array. in this case I always to only show five.
        while leaders.count > 5 {
            leaders.removeLast()
        }
        
        // returns the index of the new leaderboard entry or nil
        // if they did not make the leaderboard
        return leaders.firstIndex(where: { (entry) -> Bool in
            return entry.date == newLeader.date
        })
    }
    
    // method to load the leaderboard
    public static func loadLeaderboard() -> [Leader] {
        
        // reassuring that our store properties are the same as of our
        // memory game application managed object context within our
        // application delegate
        let managedContext: NSManagedObjectContext! =
            (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        // using ns fetch request to retrieve the data we would like
        // to use of our core data model based on our entity name
        // previously created
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Highscore")
        
        do {
            
            // attempt to fetch the expected data
            let results: [NSManagedObject] =
                try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            // instantiate an empty araray fo leaders
            // to be used as a container later on
            var leaders: [Leader] = []
            
            // loop through the results fetched accordingly
            // then create a new leaders based on the values
            // retrieve from each section within our core data model
            // which are accessed by their given key in the table
            for score in results {
                let newLeader = Leader(
                    name: score.value(forKey: "name") as! String,
                    time: score.value(forKey: "time") as! Int,
                    moves: score.value(forKey: "moves") as! Int,
                    date: score.value(forKey: "date") as! Date)
                
                // append the new leaders into our array of leaders
                leaders.append(newLeader)
            }
            
            // sort the leaders once again
            sortLeaders(leaders: &leaders)

            return leaders
        } catch {
            print("Error loading scores")
            return []
        }
    }
    
    // method to save the leaderboard
    public static func saveLeaderboard(leaders: [Leader]) {
        
        // reassuring that our stored properties are the same as our
        // memory game application managedobjectcontext
        let managedContext: NSManagedObjectContext! =
            (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        // using ns fetch request to retrieve the data we would like
        // to use of our core data model based on our entity name
        // previously created
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Highscore")
        
        // fill in our memory game highscore entity description
        // with data
        let entityDescription: NSEntityDescription! =
            NSEntityDescription.entity(forEntityName: "Highscore", in: managedContext)
        
        do {
            
            // attempting to fetch the expected data
            var results: [NSManagedObject] =
                try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            // loop through the results individually
            // and delete each one from our managed context
            for record in results {
                managedContext.delete(record)
            }
            
            // loop through the array of leaders
            for leader in leaders {
                
                // create a new element of ns managed object
                // that takes the previous entity description
                // to inserted into our managed context
                let newElement = NSManagedObject(
                    entity: entityDescription,
                    insertInto: managedContext)
                
                // assign-set values into our new managed object
                // for each columb with their appropiate forkey column
                // and value from our leader object properties
                // such as name, time, moves, date
                newElement.setValue(leader.name, forKey: "name")
                newElement.setValue(leader.time, forKey: "time")
                newElement.setValue(leader.moves, forKey: "moves")
                newElement.setValue(leader.date, forKey: "date")
                
                // append the new element into results array
                results.append(newElement)
            }
            
            // save our data into our model
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch {
            print("Error saving scores")
        }
    }
}
