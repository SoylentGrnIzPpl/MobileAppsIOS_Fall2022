//
//  ViewController.swift
//  MatchEmNav
//
//  Created by Patrick Rode on 10/9/22.
//

import UIKit

class GameSceneVC: UIViewController {
    
    
    //MARK: - ==== Config Properties ====
    
    //================================================================
    // Min and Max width and height for the rectangles
    let options = GameOptions()
    private var currentOptions = GameOptions()
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
    private var gamePaused = false
    // init the time remaining
    private lazy var gameTimeRemaining = options.gameDuration{
        didSet{gameInfoLabel?.text = gameInfo}
    }
    //var gameData = GameData()
    private var rectangleDict: [UIButton:UIButton] = [:]
    private var selectedRectangle: UIButton?
    
    @IBOutlet weak var gameInfoLabel: UILabel!
    private var gameInfo: String{
        let labelText = String(format: "⏳:%2.0f - Created:%2d - Matched:%2d", floor(gameTimeRemaining), rectanglesCreated, rectanglesMatched)
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
        
        // Swipe left nav
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftAction))
    }
    
//    @objc func swipeLeftAction(_ swipeLeft: UISwipeGestureRecognizer){
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let configVC = segue.destination as? ConfigVC
        configVC?.gameSceneVC = self
        
        if gameInProgress == true{
            if gamePaused == false{
                gamePaused = true
                pauseGame()
            }
        }
        
    }
    
    //================================================================
    override func viewWillAppear(_ animated: Bool) {
        //call super in theses methods
        super.viewWillAppear(animated)
        self.view.isMultipleTouchEnabled = true
        self.view.backgroundColor = currentOptions.backgroundColor
        if currentOptions.backgroundColor == .black{
            gameInfoLabel.textColor = .white
        }
        //start game
        //startGameRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if gameInProgress == true{
            if gamePaused == false{
                gamePaused = true
                pauseGame()
            }else{
                gamePaused = false
                resumeGame()
            }
        }
    }
    
//    @objc private func newGame(sender: UIButton){
//        if gameInProgress{return}
//
//        sender.isHidden = true
//        startGameRunning()
//    }
    
    //================================================================
    @IBAction func tapGestureAction(_ sender: UIView) {
        print("touch")
        if gameInProgress == true{
            if gamePaused == false{
                gamePaused = true
                pauseGame()
            }else{
                gamePaused = false
                resumeGame()
            }
        }
    }
    
    
    


    
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
        var randColor = Utility.getRandomColor(randomAlpha: currentOptions.randomAlpha, greyScaleMode: currentOptions.greyScaleMode)
        while randColor == currentOptions.backgroundColor{
            randColor = Utility.getRandomColor(randomAlpha: currentOptions.randomAlpha, greyScaleMode: currentOptions.greyScaleMode)
        }
//        for rectangle in rectangles {
//            if randColor == rectangle.backgroundColor{
//                randColor = Utility.getRandomColor(randomAlpha: options.randomAlpha, greyScaleMode: options.greyScaleMode)
//            }
//        }
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
        gameTimeRemaining -= currentOptions.spawnInterval
    }
    
    //================================================================
    func removeRectangle(rectangle: UIButton){
        //rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: options.fadeDuration, curve: .linear, animations: nil)
        pa.addAnimations {
            rectangle.alpha = 0.0
        }
        pa.startAnimation()
        //rectangle.removeFromSuperview()
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
    
    private func pauseGame(){
        if let timer = newRectTimer{ timer.invalidate()}
        if let timer = gameTimer{timer.invalidate()}
    }
    
    private func resumeGame(){
        newRectTimer = Timer.scheduledTimer(withTimeInterval: currentOptions.spawnInterval, repeats: true){
            _ in self.createRectangle()
        }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameTimeRemaining, repeats: false){
            _ in self.stopGameRunning()
        }
    }
    
    private func startGameRunning(){
        
        currentOptions = GameOptions()
        
        removeAllRectangles()
        rectanglesCreated = 0
        rectanglesMatched = 0
        gameTimeRemaining = currentOptions.gameDuration
        selectedRectangle = nil
        // timer to produce the rectangles
        newRectTimer = Timer.scheduledTimer(withTimeInterval: currentOptions.spawnInterval, repeats: true){
            _ in self.createRectangle()
        }
        // timer to end game
        gameTimer = Timer.scheduledTimer(withTimeInterval: currentOptions.gameDuration, repeats: false){
            _ in self.stopGameRunning()
        }
        
        gameInProgress = true
        
        //init label colors
        if currentOptions.backgroundColor == .black{
            gameInfoLabel.textColor = .white
        }else{
            gameInfoLabel.textColor = .black
        }
        
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
        if currentOptions.backgroundColor == .black{
            gameInfoLabel.backgroundColor = .white
        }else{
            gameInfoLabel.backgroundColor = .black
        }
        
        var newScore = rectanglesMatched
        for i in 0...2 {
            if options.highScores[i] < newScore{
                //print(newScore)
                let oldScore = options.highScores[i]
                options.highScores[i] = newScore
                newScore = oldScore
            }
        }
        options.defaults.set(options.highScores, forKey: "highScores")
        
    }
}

class GameOptions{
    
    let defaults = UserDefaults.standard
    
    let rectSizeMin:CGFloat = 50.0
    let rectSizeMax:CGFloat = 150.0
    //rectangle opacity
    var randomAlpha = false
    // how long for the rectangle to fade
    var fadeDuration: TimeInterval = 0.8
    // rectangle creation interval
    var spawnInterval: TimeInterval = 1.0

    // game duration
    var gameDuration: TimeInterval = 15.0
    
    var greyScaleMode:Bool = false
    
    var backgroundColor:UIColor = .white//UIColor(red:1,green:1,blue:1, alpha:1)
    
    var highScores:[Int] = [0,0,0]
    
    init(){
        let defaults = UserDefaults.standard
        //self.spawnInterval = defaults.double(forKey: "spawnInterval")
        if(defaults.object(forKey: "spawnInterval") != nil){
            self.spawnInterval = defaults.double(forKey: "spawnInterval")
        }else{
            defaults.set(Double(1.0), forKey: "spawnInterval")
        }
        
        if(defaults.object(forKey: "gameDuration") != nil){
            self.gameDuration = defaults.double(forKey: "gameDuration")
        }else{
            defaults.set(Double(15.0), forKey: "gameDuration")
        }
        
        if(defaults.object(forKey: "greyScaleMode") != nil){
            self.greyScaleMode = defaults.bool(forKey: "greyScaleMode")
        }
        
        if(defaults.object(forKey: "backgroundColor") != nil){
            let colorIndex = defaults.integer(forKey: "backgroundColor")
            if colorIndex == 0{
                self.backgroundColor = .white
            }else if colorIndex == 1{
                self.backgroundColor = .black
            }else if colorIndex == 2{
                self.backgroundColor = .red
            }else if colorIndex == 3{
                self.backgroundColor = .green
            }else if colorIndex == 4{
                self.backgroundColor = .blue
            }else{
                self.backgroundColor = .white
            }
        }
        
        if(defaults.object(forKey: "highScores") != nil){
            self.highScores = defaults.array(forKey: "highScores") as? [Int] ?? [0,0,0]
        }
    }
    
    init(gameDuration: TimeInterval, spawnInterval: TimeInterval){
        self.gameDuration = gameDuration
        self.spawnInterval = spawnInterval
    }
    
}
