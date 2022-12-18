//
//  ViewController.swift
//  MatchEmScene
//
//  Created by Patrick Rode on 10/9/22.
//

import UIKit

class GameSceneVC: UIViewController {
    //MARK: - ==== Config Properties ====
    
    //================================================================
    // Min and Max width and height for the rectangles
    let options = GameOptions(gameDuration: TimeInterval(12), spawnInterval: TimeInterval(1))


    // hide status bar
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
    //MARK: - ==== Internal Properties ====
    // rectangle creation, so timer can be stopped
    private var newRectTimer: Timer?
    // Game timer
    private var gameTimer: Timer?
    //keep track of all rectangles created
    private var rectangles = [UIButton]()
    private var rectanglesCreated = 0{
        didSet {gameInfoLabel?.text = gameInfo}
    }
    private var rectanglesMatched = 0{
        didSet {gameInfoLabel?.text = gameInfo}
    }
    // game in progress
    private var gameInProgress = false
    // init the time remaining
    private lazy var gameTimeRemaining = options.gameDuration{
        didSet{gameInfoLabel?.text = gameInfo}
    }
    var gameData = GameData()
    private var rectangleDict: [UIButton:UIButton] = [:]
    private var selectedRectangle: UIButton?
    
    @IBOutlet weak var gameInfoLabel: UILabel!
    private var gameInfo: String{
        let labelText = String(format: "⏳:%2.0f - Created:%2d - Matched:%2d", gameTimeRemaining, rectanglesCreated, rectanglesMatched)
        return labelText
    }
    
    
    @IBOutlet weak var newGameButton: UIButton!
    //newGameButton.frame.origin = CGPoint(x:0, y:0)

    
    @IBAction func startGameButton(_ sender: UIButton) {
        if gameInProgress{return}
        
        sender.isHidden = true
        startGameRunning()
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
        
        //start game
        //startGameRunning()
    }
    
//    @objc private func newGame(sender: UIButton){
//        if gameInProgress{return}
//
//        sender.isHidden = true
//        startGameRunning()
//    }
    
    //================================================================
    @objc private func handleTouch(sender: UIButton){
        if !gameInProgress {return}
        //print("\(#function) - \(sender)")
        //add emoji text to rectangle
        sender.setTitle("💀", for: .normal)
        //rectanglesMatched += 1
        // remove the rectangle
        if selectedRectangle != nil{
            if rectangleDict[sender] == selectedRectangle!{
                removeRectangle(rectangle: sender)
                removeRectangle(rectangle: selectedRectangle!)
                selectedRectangle = nil
                rectanglesMatched += 1
            }else{
                selectedRectangle!.setTitle("", for: .normal)
                sender.setTitle("", for: .normal)
                selectedRectangle = nil
            }
        }else{
            selectedRectangle = sender
        }
        //removeRectangle(rectangle: sender)
        //sender.removeFromSuperview()
    }

}

// MARK: - ==== Rectangle Methods ====
extension GameSceneVC{
    
    //================================================================
    private func createRectangle(){
        // get random values for size and location
        let randSize = Utility.getRandomSize(fromMin: options.rectSizeMin, throughMax: options.rectSizeMax)
        
        var gameArea = view.bounds.size
        gameArea.height = gameInfoLabel.frame.minY - view.safeAreaInsets.top
        //print(gameArea.height)
        var randLocation1 = Utility.getRandomLocation(size: randSize, screenSize: gameArea)
        randLocation1.y += view.safeAreaInsets.top
        var randLocation2 = Utility.getRandomLocation(size: randSize, screenSize: gameArea)
        randLocation2.y += view.safeAreaInsets.top
        
        let randomFrame1 = CGRect(origin: randLocation1, size: randSize)
        let randomFrame2 = CGRect(origin: randLocation2, size: randSize)
        // Create rectangle
        //let rectangleFrame = CGRect(x:50, y:150, width:80, height:40)
        let rectangle1 = UIButton(frame: randomFrame1)
        let rectangle2 = UIButton(frame: randomFrame2)
        // increment rectanglesCreated
        rectanglesCreated += 1
        //save rectangle until game is over
        rectangles.append(rectangle1)
        rectangles.append(rectangle2)
        
        rectangleDict[rectangle1] = rectangle2
        rectangleDict[rectangle2] = rectangle1
        
        // Rectangle button setup
        let randColor = Utility.getRandomColor(randomAlpha: options.randomAlpha)
        rectangle1.backgroundColor = randColor
        rectangle2.backgroundColor = randColor
        rectangle1.setTitle("", for: .normal)
        rectangle2.setTitle("", for: .normal)
        rectangle1.setTitleColor(.black, for: .normal)
        rectangle2.setTitleColor(.black, for: .normal)
        rectangle1.titleLabel?.font = .systemFont(ofSize: 50)
        rectangle2.titleLabel?.font = .systemFont(ofSize: 50)
        //rectangle.showsTouchWhenHighlighted = true
        
        // Target/action to set up connect of button to VC
        rectangle1.addTarget(self, action: #selector(self.handleTouch(sender:)), for: .touchUpInside)
        rectangle2.addTarget(self, action: #selector(self.handleTouch(sender:)), for: .touchUpInside)
        
        // Make Rectangle Visible
        self.view.addSubview(rectangle1)
        self.view.addSubview(rectangle2)
        //bring label to front
        view.bringSubviewToFront(gameInfoLabel!)
        
        // decrement game time remaining
        gameTimeRemaining -= options.spawnInterval
    }
    
    //================================================================
    func removeRectangle(rectangle: UIButton){
        //rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: options.fadeDuration, curve: .linear, animations: nil)
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
        rectanglesCreated = 0
        rectanglesMatched = 0
        gameTimeRemaining = options.gameDuration
        selectedRectangle = nil
        // timer to produce the rectangles
        newRectTimer = Timer.scheduledTimer(withTimeInterval: options.spawnInterval, repeats: true){
            _ in self.createRectangle()
        }
        // timer to end game
        gameTimer = Timer.scheduledTimer(withTimeInterval: options.gameDuration, repeats: false){
            _ in self.stopGameRunning()
        }
        gameInProgress = true
        
        //init label colors
        gameInfoLabel.textColor = .black
        gameInfoLabel.backgroundColor = .clear
    }
    
    //================================================================
    private func stopGameRunning(){
//        let frame = CGRect(origin: CGPoint(x: rectX, y: rectY), size: CGSize(width: randWidth, height: randHeight))
//        let newGameButton = UIButton
        
        
        // stop the timer
        if let timer = newRectTimer{ timer.invalidate()}
        
        //remove reference to timer object
        self.newRectTimer = nil
        gameInProgress = false
        newGameButton.isHidden = false
        view.bringSubviewToFront(newGameButton)
        
        // end of game, no time left, update info label
        gameTimeRemaining = 0.0
        gameInfoLabel?.text = gameInfo
        
        // make label stand out
        gameInfoLabel.textColor = .red
        gameInfoLabel.backgroundColor = .black
        
    }
}

