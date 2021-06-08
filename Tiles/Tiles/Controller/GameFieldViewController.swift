//
//  GameFieldViewController.swift
//  Tiles
//
//  Created by Norberto Taveras on 6/8/21.
//

import UIKit
import CoreData

class GameFieldViewController: UIViewController {

    @IBOutlet var tilesCollection: [UIView]!
    @IBOutlet var tilesImageCollection: [UIImageView]!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var movesLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    // default player name
    public var playerName: String = ""
    
    // current game difficulty by default
    // to be retrieved from the main view controller
    public var difficulty: MainViewController.Difficulty = .normal
    
    // colors for the foreground and backgroud
    // of the tiles within the game
    let tileColorF = UIColor.init(
        red: 31.0/255.0,
        green: 32.0/255.0,
        blue: 33.0/255.0,
        alpha: 1.0)
    
    let tileColorB = UIColor.init(
        red: 239.0/255.0,
        green: 154.0/255.0,
        blue: 85.0/255.0,
        alpha: 1.0)
    
    // the maximum of rows and columns
    // to be represented in the game grid
    let maxCols: Int = 5
    let maxRows: Int = 6
    
    // the initial reveal time of the game tiles
    var revealTime: Int = 5
    
    // variable for the number of game tiles
    var numOfTiles: Int = 0
    
    // array of integers to represent the flipped image indexes
    var flippedImageIndexes: [Int] = []
    
    // variable for the game time
    var timer: Timer?
    
    // the game start date
    var gameStarted: Date?
    
    // the game end date
    var gameEnded: Date?
    
    // the player moves count
    var moveCount: Int = 0
    
    // the numbers of pairs left count
    var numOfPairsLeft: Int = 0
    
    // the game score
    var score: Int = 0
    
    // method to return the number of pairs on the presented
    // device by dividing in half the available tiles on a device
    // whether it's an iphone or ipad
    private var NumberOfPairs: Int {
        return tileLookUp.count / 2
    }
    
    // array of tiles that are visible on the current device
    var tileLookUp: [UIView] = []
    
    // array of image views that are visible on the current device
    var imageLookUp: [UIImageView] = []
    
    // the game state machine to handle various states
    // that the memory game could go through in the process
    private enum GameState {
        case new
        case revealed
        case playing
        case wrong
        case right
        case victory
    }
    
    // the initial game state of the memory game
    private var state: GameState = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachTouchHandlers()
    }

    override func viewWillAppear(_ animated: Bool) {
        // checking if the current state of the game is new
        // if it is new, then assign the state to the revealed state
        if state == .new {
            state = .revealed
            
            // switch on the current game difficulty
            // and set different reveal times of the tiles
            switch difficulty {
            case .easy:
                revealTime = 6
            case .normal:
                revealTime = 5
            case .hard:
                revealTime = 0
            default:
                break
            }
            
            // create a timer that repeats every one second
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true) { (t) in
                // run update per second
                self.secondsTick()
            }
            
            // checking if the current device is an ipad
            // if it is, there will be an extra row and columns of tiles
            // by appending the tilesCollection and tilesImageCollection
            // into their corresponding containers.
            // otherwise when the current device is a phone
            // the grid will be treated as a two dimensional layout
            if UIDevice.current.userInterfaceIdiom == .pad {
                tileLookUp.append(contentsOf: tilesCollection)
                imageLookUp.append(contentsOf: tilesImageCollection)
            } else {
                // variable to keep track of the indexes
                // for the tile and image to be appended into
                // each lookup container
                var i = 0
                
                // since the grid is two dimensional
                // it's essential to loop through each row
                // and columns based on the max rows and columns
                // by substracting one to the maximum of columns and rows
                // we ensure the appropiate amount of rows and columns for phones
                for row in 0 ..< maxRows {
                    for col in 0 ..< maxCols {
                        if col < maxCols - 1 && row < maxRows - 1 {
                            tileLookUp.append(tilesCollection[i])
                            imageLookUp.append(tilesImageCollection[i])
                        }
                        i += 1
                    }
                }
            }
            
            // loop through the collection of tiles
            // and set eqach tiles corner radius to six
            for tile in tilesCollection {
                tile.layer.cornerRadius = 6
            }
            
            // method of resetGame(), allows to reset the game
            resetGame()
        }
    }
    
    // method to start the initial play and state
    // of the memory game
    public func startInitialPlay() {
        state = .playing
        gameStarted = Date.init()
        gameEnded = nil
        
        resetMoves()
        
        toggleStatusVisibility(visible: true)
        toggleAllImageVisibility(visible: false)
    }
    
    // method to reset the game accordingly
    public func resetGame() {
        clearImages()
        
        // randomize the tiles
        randomizeTiles()
        
        // do this immediately
        toggleStatusVisibility(visible: false)
        toggleAllTileVisibility(visible: true)
        toggleAllImageVisibility(visible: true)
        
        // creating a delay to let the user memorize a few of the tiles
        // revealTime controls the delay
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(revealTime)) {
            // Do this `revealTime` seconds later
            self.startInitialPlay()
        }
    }
    
    // method that takes two dates and return a string with a
    // specified format of hh:mm:ss representing the amount of time
    // between the given two dates
    public static func timeStringBetween(startDate: Date, endDate: Date) -> (text: String, seconds: Int) {
        
        // get the amount of time between them in seconds
        let since = endDate.timeIntervalSince(startDate)
        
        // convert the time inteveral into integers
        let totalSeconds = Int(since)
        
        // wrap seconds to within 0-59 range
        let seconds = totalSeconds % 60
        
        // 60 seconds per minute
        let totalMinutes = totalSeconds / 60
        
        // wrap minutes to 0-59 range
        let minutes = totalMinutes % 60
        
        // 60 minutes per hour
        let totalHours = totalMinutes / 60
        
        // force the numbers to be at least
        // 2 digits long with leading zeros
        let hrsStr = String(format: "%02d", totalHours)
        let minStr = String(format: "%02d", minutes)
        let secStr = String(format: "%02d", seconds)
        
        return (
            text: "\(hrsStr):\(minStr):\(secStr)",
            seconds: totalSeconds
        )
    }
    
    public func secondsTick() {
        // check if the game started, then update the time display
        if let started = gameStarted {
            
            // use either the date when the game ended,
            // or use now as the "end date" if the game
            // has not ended
            let durationInfo = GameFieldViewController.timeStringBetween(
                startDate: started,
                endDate: gameEnded ?? Date())
            timeLabel.text = durationInfo.text
        }
    }
    
    // method to attach ui tap gesture recognizer
    // in all uiviews part of the tiles collection
    func attachTouchHandlers() {
        for tile in tilesCollection {
            
            // create a tap recognizer
            let tapGesture = UITapGestureRecognizer.init(
                target: self,
                action: #selector (self.tileTapped))
            
            // set interaction enabled to true
            tile.isUserInteractionEnabled = true
            
            // add the gesture recognizer
            tile.addGestureRecognizer(tapGesture)
        }
    }
    
    // method to handle when a tile is tapped by the player
    @objc func tileTapped(sender: UITapGestureRecognizer) {
        guard state == .playing
            else {return}
        
        // ignore gestures that are not in "ended" state
        guard sender.state == .ended
            else {return}
        
        // skips and ignores gestures that do not have a view
        guard let senderView = sender.view
            else {return}
        
        // gets the first index of the tile lookup collection
        let index = tileLookUp.firstIndex(of: senderView) ?? -1
        
        // lookup whether we have already flipped that one, and
        // find out which index that one is in the already flipped list
        let alreadyIndex = flippedImageIndexes.firstIndex(of: index) ?? -1
        
        // check if we can find that index
        // in the list of already flipped up tiles
        var newState: Bool = false
        
        // check the index of the already flipped tile/image
        if alreadyIndex >= 0 {
            // tile was already flipped
            // user is giving up on that tile.
            // kid mode could allow peeking at tiles, this would unflip it
            // code below won't allow it though, for now
            newState = false
        } else if flippedImageIndexes.count < 2 {
            // wasn't flipped
            newState = true
        }
        
        // if the user is trying to cheat by peeking at single
        // tiles and flipping back over, disallow that
        // allowed on easy though
        if newState == false && flippedImageIndexes.count == 1 &&
            difficulty != .easy {
            // It is not on easy so block the user flipping
            // On normal and hard you are not allowed to flip
            // tiles back down, so return
            return
        }
        
        // make the tile reveal if appropriate
        setImageReveal(index: index, revealed: newState)
        
        if newState {
            // was flipped up, add to list of flipped up tile indexes
            flippedImageIndexes.append(index)
        } else if alreadyIndex >= 0 {
            // kid flipped image back down, done peeking
            flippedImageIndexes.remove(at: alreadyIndex)
        }
        
        var right: Bool? = nil
        
        // if the player now has two flipped
        if flippedImageIndexes.count == 2 {
            // then get the references to the two images that they flipped
            let img1 = imageLookUp[flippedImageIndexes[0]].image
            let img2 = imageLookUp[flippedImageIndexes[1]].image
            
            // right will be true if they flipped two identical images
            // right will be false if they flipped two different images
            // right will be nil if they didn't flip two over yet
            right = img1 == img2
            /*if img1 == img2 {
             right = true
             } else {
             right = false
             } */
        }
        
        if right != nil {
            // User has selected a second tile, and it is either right or wrong
            state = right != false ? .right : .wrong
            /* if right != false {
             state = .right
             } else {
             state = .wrong
             } */
            self.incrementMoves()
            
            if right == true {
                DispatchQueue.main.async {
                    self.incrementScores()
                }
            }
            // whether the user did a successful or unsuccessful match,
            // always let them see the second one they flipped
            // for half of a second
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                // this runs half a second later
                
                // decide what to do based on whether the tiles matched
                if self.state == .right {
                    // correct matches make both tiles entirely disappear
                    self.makeFlippedDisappear()
                } else {
                    // wrong choice, flip all tiles down
                    self.toggleAllImageVisibility(visible: false)
                }
                
                // nothing is flipped anymore
                self.flippedImageIndexes.removeAll()
                
                // player can make another play now
                if self.numOfPairsLeft > 0 {
                    // there are tiles remaining, put it back to playing
                    self.state = .playing
                }
            }
        }
    }
    
    // reset the move counter to zero and update the display
    private func resetMoves() {
        numOfPairsLeft = NumberOfPairs
        moveCount = 0
        score = 0
        movesLabel.text = "Moves: 0"
        scoreLabel.text = "Score: 0"
    }
    
    // method to update the moves count that the player does
    // during the game, increment by one
    private func incrementMoves() {
        moveCount += 1
        movesLabel.text = "Moves: \(moveCount.description)"
    }
    
    // method to update the score value based
    // on the difficulty chosen by the player
    private func incrementScores() {
        switch difficulty {
        case .easy:
            score += 1
        case .normal:
            score += 2
        case .hard:
            score += 4
        default:
            break;
        }
        scoreLabel.text = "Score: \(score.description)"
    }
    
    
    // for both of them disappear
    private func makeFlippedDisappear() {
        
        setTileVisibility(
            index: flippedImageIndexes[0],
            visible: false)
        
        setTileVisibility(
            index: flippedImageIndexes[1],
            visible: false)
        
        numOfPairsLeft -= 1
        
        // set this to true to enable developer cheats, enabling
        // you to win by making a single match
        let devCheat = false
        
        // If there are no pairs left, or it is a developer that
        // is trying to get his assignment done fast, then
        // call win
        if numOfPairsLeft == 0 || devCheat {
            win()
        }
    }
    
    // method to handle the win scenarion
    // after the player has won
    private func win() {
        // update the state to prevent further plays
        state = .victory
        
        // remember exactly when the game was finished
        gameEnded = Date()
        
        // Take the user to the victory screen
        performSegue(withIdentifier: "victoryView", sender: self)
    }
    
    // override of prepare for segue method
    // to pass the game start date, end date and moves count
    // into the victory view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "victoryView":
            // pass the appropiate information into the victory view controller
            if let destination = segue.destination as? VictoryViewController {
                let durationInfo = GameFieldViewController.timeStringBetween(
                    startDate: gameStarted!,
                    endDate: gameEnded!)
                destination.durationText = durationInfo.text
                destination.duration = durationInfo.seconds
                destination.movesText = moveCount.description
                destination.moves = moveCount
                destination.playerName = playerName
            }
        default:
            break
        }
    }
    
    // method to update the tile
    // visiblity based on the index of the tiles
    // being looked at
    private func setTileVisibility(index: Int, visible: Bool) {
        tileLookUp[index].isHidden = !visible
    }
    
    // method to set the image to be revealed
    // based on image and tilve index within their respective
    // lookup containers
    private func setImageReveal(index: Int, revealed: Bool) {
        // get a reference to the specified image
        let imageView = imageLookUp[index]
        
        // get a reference to the specified tile view
        let tileView = tileLookUp[index]
        
        // update the visibility of the image and change
        // the background color to make it as if the tiles
        // are different colors on both sides
        imageView.isHidden = !revealed
        tileView.backgroundColor =
            revealed ? tileColorF : tileColorB
    }
    
    // method to return the specific tile by index
    // only the ones visible in the current device
    private func tileAt(index: Int) -> UIView {
        return tileLookUp[index]
    }
    
    // method to return the specific image for the speficic
    // tile by index
    private func tileImageAt(index: Int) -> UIImageView? {
        return imageLookUp[index]
    }
    
    // the status bar is removed to reduce distraction
    // while the user is trying to memorize some tiles
    // at the beginning
    func toggleStatusVisibility(visible: Bool) {
        movesLabel.isHidden = !visible
        timeLabel.isHidden = !visible
        scoreLabel.isHidden = !visible
    }
    
    // method to show or hide every tile's image
    // based on the index and visibility bolean value
    func toggleAllImageVisibility(visible: Bool) {
        
        // loop through the image lookup count
        // set each image to be show or hide by index
        for index in 0 ..< imageLookUp.count {
            setImageReveal(index: index, revealed: visible)
        }
    }
    
    // method to show or hide every tile
    // based on the index and boolean visibility value
    func toggleAllTileVisibility(visible: Bool) {
        for index in 0 ..< tileLookUp.count {
            setTileVisibility(index: index, visible: visible)
        }
    }
    
    // wipe out the images to prepare
    // to generate a different mix of images
    
    // clear out the images to prepare
    // to generate a different mix of images
    func clearImages() {
        for imageView in tilesImageCollection {
            imageView.image = nil
        }
    }
    
    // method to randomize the tiles within the board
    func randomizeTiles() {
        
        // array of integers to store the remaining images to be paired
        // in the board by the player
        var remainingImages: [Int] = []
        
        // loop through tiles images namelist count
        // append each choice into the remaining images container
        for choice in 0 ..< TileImages.nameList.count {
            remainingImages.append(choice)
        }
        
        // a list of name indexes for each pair for each image chosen
        var pairs: [Int] = []
        
        // loop through the number of pairs
        // select one random image per pair
        for _ in 0 ..< NumberOfPairs {
            
            // pick a random index in remaining images
            let remainingImagesIndex = Int.random(
                in: 0 ..< remainingImages.count)
            
            // read the chosen image index
            let index = remainingImages[remainingImagesIndex]
            
            // remove it from the set of possible images
            remainingImages.remove(at: remainingImagesIndex)
            
            // append the image index of the pair
            pairs.append(index)
            pairs.append(index)
        }
        
        // shuffle the pairs
        pairs.shuffle()
        
        // keep a lookup table of images, so we can reuse the 1st one
        // when we place it on the second tile
        var imageCache: [Int: UIImage] = [:]
        
        // apply the images to each tile
        for (index, imageNr) in pairs.enumerated() {
            // lookup the image name from the chosen image index
            var image: UIImage? = imageCache[imageNr]
            
            // in case that the player has never seen this image before
            if image == nil {
                // get the name for this image
                let imageName = TileImages.nameList[imageNr]
                
                // load the image
                image = UIImage.init(named: imageName)
                
                // remember the image for this image number
                // so the other tile with this image can
                // just share the same one and use half
                // of the memory
                imageCache[imageNr] = image
            }
            
            // assign the image that we had or just made
            let tileImgView = tileImageAt(index: index)
            tileImgView?.image = image
        }
    }
    
    // unwind segue to return to the appropiate storyboard
    // handles resetting the game
    @IBAction func playAnotherGame(segue: UIStoryboardSegue ) {
        resetGame()
    }
    
    // ib action for the pop-up modal
    // checks if the current state of the game is not equal to playing
    // if true, it will dismiss the current view or storyboard being looke dat
    // this function also prompt the user with a quit or continue playing modal
    // if they attempt to quit while in the middle of the game
    // if they press stop while not in the middle of the game, it will
    // just dismiss to the previous view
    @IBAction func giveUp(_ sender: Any) {
        if state != .playing {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController.init(
            title: "Quit Game",
            message: "Are you sure you want to give up?",
            preferredStyle: .alert)
        
        let yesButton = UIAlertAction.init(
            title: "Quit",
            style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
        }
        
        let noButton = UIAlertAction.init(
            title: "Continue Playing", style: .default, handler: nil)
        
        alert.addAction(yesButton)
        alert.addAction(noButton)
        present(alert, animated: true, completion: nil)
    }
}
