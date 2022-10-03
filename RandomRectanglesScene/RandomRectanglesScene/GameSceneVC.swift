//
//  ViewController.swift
//  RandomRectanglesScene
//
//  Created by Patrick Rode on 10/2/22.
//

import UIKit

class GameSceneVC: UIViewController {
    //MARK: - ==== Config Properties ====
    
    //================================================================
    // Min and Max width and height for the rectangles
    private let rectSizeMin:CGFloat = 50.0
    private let rectSizeMax:CGFloat = 150.0
    //rectangle opacity
    private var randomAlpha = false
    // how long for the rectangle to fade
    private var fadeDuration: TimeInterval = 0.8
    // rectangle creation interval
    private var newRectInterval: TimeInterval = 1.2
    // rectangle creation, so timer can be stopped
    private var newRectTimer: Timer?
    // game duration
    private var gameDuration: TimeInterval = 10.0
    // Game timer
    private var gameTimer: Timer?
    // hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
    //MARK: - ==== Internal Properties ====
    //keep track of all rectangles created
    private var rectangles = [UIButton]()
    private var rectanglesCreated = 0{
        didSet {gameInfoLabel?.text = gameInfo}
    }
    private var rectanglesTouched = 0{
        didSet {gameInfoLabel?.text = gameInfo}
    }
    // game in progress
    private var gameInProgress = false
    // init the time remaining
    private lazy var gameTimeRemaining = gameDuration{
        didSet{gameInfoLabel?.text = gameInfo}
    }
    var gameData = GameData()
    
    @IBOutlet weak var gameInfoLabel: UILabel!
    private var gameInfo: String{
        let labelText = String(format: "Time:%2.0f - Created:%2d - Touched:%2d", gameTimeRemaining, rectanglesCreated, rectanglesTouched)
        return labelText
    }
    
    //MARK: - ==== View Controller Methods ====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //================================================================
    override func viewWillAppear(_ animated: Bool) {
        //call super in theses methods
        super.viewWillAppear(animated)
        
        //create single rectangle
        //createRectangle()
        //createRectangle()
        //createRectangle()
        
        //start game
        startGameRunning()
    }
    
    //================================================================
    @objc private func handleTouch(sender: UIButton){
        if !gameInProgress {return}
        //print("\(#function) - \(sender)")
        //add emoji text to rectangle
        sender.setTitle("💀", for: .normal)
        rectanglesTouched += 1
        // remove the rectangle
        removeRectangle(rectangle: sender)
        //sender.removeFromSuperview()
    }

}

// MARK: - ==== Rectangle Methods ====
extension GameSceneVC{
    
    //================================================================
    private func createRectangle(){
        // get random values for size and location
        let randSize = Utility.getRandomSize(fromMin: rectSizeMin, throughMax: rectSizeMax)
        let randLocation = Utility.getRandomLocation(size: randSize, screenSize: view.bounds.size)
        let randomFrame = CGRect(origin: randLocation, size: randSize)
        // Create rectangle
        //let rectangleFrame = CGRect(x:50, y:150, width:80, height:40)
        let rectangle = UIButton(frame: randomFrame)
        // increment rectanglesCreated
        rectanglesCreated += 1
        //save rectangle until game is over
        rectangles.append(rectangle)
        
        // Rectangle button setup
        rectangle.backgroundColor = Utility.getRandomColor(randomAlpha: randomAlpha)
        rectangle.setTitle("", for: .normal)
        rectangle.setTitleColor(.black, for: .normal)
        rectangle.titleLabel?.font = .systemFont(ofSize: 50)
        //rectangle.showsTouchWhenHighlighted = true
        
        // Target/action to set up connect of button to VC
        rectangle.addTarget(self, action: #selector(self.handleTouch(sender:)), for: .touchUpInside)
        
        // Make Rectangle Visible
        self.view.addSubview(rectangle)
        //bring label to front
        view.bringSubviewToFront(gameInfoLabel!)
        
        // decrement game time remaining
        gameTimeRemaining -= newRectInterval
    }
    
    //================================================================
    func removeRectangle(rectangle: UIButton){
        //rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: fadeDuration, curve: .linear, animations: nil)
        pa.addAnimations {
            rectangle.alpha = 0.0
        }
        pa.startAnimation()
    }
    
    //================================================================
    func removeAllRectangles(){
        //remove all rectangles from superview
        for rectangle in rectangles {
            rectangle.removeFromSuperview()
        }
        // clear rectangles array
        rectangles.removeAll()
    }
}

//MARK: - ==== Timer Functions ====
extension GameSceneVC {
    //================================================================
    private func startGameRunning(){
        removeAllRectangles()
        // timer to produce the rectangles
        newRectTimer = Timer.scheduledTimer(withTimeInterval: newRectInterval, repeats: true){
            _ in self.createRectangle()
        }
        // timer to end game
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameDuration, repeats: false){
            _ in self.stopGameRunning()
        }
        gameInProgress = true
        
        //init label colors
        gameInfoLabel.textColor = .black
        gameInfoLabel.backgroundColor = .clear
    }
    
    //================================================================
    private func stopGameRunning(){
        // stop the timer
        if let timer = newRectTimer{ timer.invalidate()}
        
        //remove reference to timer object
        self.newRectTimer = nil
        gameInProgress = false
        
        // end of game, no time left, update info label
        gameTimeRemaining = 0.0
        gameInfoLabel?.text = gameInfo
        
        // make label stand out
        gameInfoLabel.textColor = .red
        gameInfoLabel.backgroundColor = .black
        
    }
}
