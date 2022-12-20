//
//  GameScene.swift
//  CubeDestroyer
//
//  Created by Patrick Rode on 12/15/22.
//

// importing libraries
import SpriteKit


// Overloading operators for vector math
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

// idk what this is for thb
#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

// adding functionality to CGPoint for vector math
extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}


class GameScene: SKScene{
    // MARK: Config variables needed in class scope
    
    // Bit Masks for physics engine collisions
    struct PhysCat{
        static let none:UInt32 = 0x00
        static let all:UInt32 = UInt32.max
        static let cube:UInt32 = 0b1
        static let lazer:UInt32 = 0b10
        static let base:UInt32 = 0b100
    }
    
    // Game Settings
    
    // View Controller for scene
    var gameVC:GameVC?
    
    // Cube and spaceship settings
    var health = 50{
        didSet{
            gameVC?.healthLabelOutlet.text! = "Health\n" + String(health)
        }
    }
    var cubesDestroyed = 0{
        didSet{
            gameVC?.scoreLabelOutlet.text! = "Score\n" + String(cubesDestroyed)
        }
    }
    var fireRate:Int?
    var spawnRate:Int?
    var cubeScale:CGSize?
    var randCubeScale:Bool?
    var randCubeColor:Bool?
    var cubeHealth:Int?
    var cubeSpeed:Float?
    var cubeSpeedVariance:Float?
    
    // Vars for high scores
    var hsNameArray = Array(repeating: String("None"), count:10)
    var hsScoreArray = Array(repeating: Int(0), count:10)
    var hsIndex = 0
    var highScore = 0
    var gameActive = false{
        didSet{
            for gesture in (gameVC?.view.gestureRecognizers)!{
                gesture.isEnabled = !gameActive
            }
        }
    }
    
    // vars for speed and image of background nodes
    let bgSpeed = 60.0
    var bgImage = true
    
    // Setting up other essential nodes
    var base = SKShapeNode()
    let spaceShip = SKSpriteNode(imageNamed: "spaceShip")
    
    
    // Triggered when view is moved by GameVC
    override func didMove(to view: SKView){
        // MARK: loading stuff from userdefaults
        let defaults = UserDefaults.standard
        
        if UserDefaults.standard.object(forKey: "hsNameArray") != nil{
            hsNameArray = UserDefaults.standard.array(forKey: "hsNameArray") as? [String] ?? Array(repeating: String("None"), count:10)
        }
        if UserDefaults.standard.object(forKey: "hsNameArray") != nil{
            hsScoreArray = UserDefaults.standard.array(forKey: "hsScoreArray") as? [Int] ?? Array(repeating: Int(0), count:10)
        }
        
        if defaults.object(forKey: "cubeHealth") != nil{
            cubeHealth = Int(defaults.integer(forKey: "cubeHealth"))
        }else{
            cubeHealth = 1
            defaults.setValue(Int(cubeHealth!), forKey: "cubeHealth")
        }
        
        if defaults.object(forKey: "health") != nil{
            health = Int(defaults.integer(forKey: "health"))
        }else{
            health = 50
            defaults.setValue(Int(health), forKey: "health")
        }
        
        if defaults.object(forKey: "fireRate") != nil{
            fireRate = Int(defaults.integer(forKey: "fireRate"))
        }else{
            fireRate = 1
            defaults.setValue(fireRate, forKey: "fireRate")
        }
        
        if defaults.object(forKey: "spawnRate") != nil{
            spawnRate = defaults.integer(forKey: "spawnRate")
        }else{
            spawnRate = 1
            defaults.setValue(spawnRate, forKey: "spawnRate")
        }
        
        if defaults.object(forKey: "randCubeScale") != nil{
            randCubeScale = defaults.bool(forKey: "randCubeScale")
        }else{
            randCubeScale = false
            defaults.setValue(randCubeScale, forKey: "randCubeScale")
        }
        
        if defaults.object(forKey: "randCubeColor") != nil{
            randCubeColor = defaults.bool(forKey: "randCubeColor")
        }else{
            randCubeColor = false
            defaults.setValue(randCubeColor, forKey: "randCubeColor")
        }
        if defaults.object(forKey: "cubeSpeed") != nil{
            cubeSpeed = defaults.float(forKey: "cubeSpeed")
        }else{
            cubeSpeed = 4.0
            defaults.setValue(cubeSpeed, forKey: "cubeSpeed")
        }
        if defaults.object(forKey: "cubeSpeedVariance") != nil{
            cubeSpeedVariance = defaults.float(forKey: "cubeSpeedVariance")
        }else{
            cubeSpeedVariance = 10.0
            defaults.setValue(cubeSpeedVariance, forKey: "cubeSpeedVariance")
        }
        
        
        // MARK: Setting up basic scene nodes
        // Run background animations
        addBackground()
        run(SKAction.sequence([SKAction.wait(forDuration: bgSpeed * 0.33), SKAction.repeatForever(SKAction.sequence([SKAction.run(loopSpaceBG), SKAction.wait(forDuration: bgSpeed * 0.65)]))]))
        backgroundColor = .white
        
        // Add spaceship
        spaceShip.scale(to: CGSize(width: 50, height: 50) )
        spaceShip.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1 + 10)
        spaceShip.zPosition = 1
        addChild(spaceShip)
        
        // Add base
        base.removeFromParent()
        base = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: size.height * 0.15), size: CGSize(width: size.width, height: size.height * 0.05)))
        base.fillColor = .systemBlue
        base.alpha = 0.5
        base.zPosition = 1
        addChild(base)
        base.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: size.height * 0.2), to: CGPoint(x: size.width, y: size.height * 0.2))
        base.physicsBody?.isDynamic = true
        base.physicsBody?.categoryBitMask = PhysCat.base
        base.physicsBody?.contactTestBitMask = PhysCat.cube
        base.physicsBody?.collisionBitMask = PhysCat.none
        
        run(SKAction.playSoundFileNamed("galagaMusic", waitForCompletion: false))
        
        // Physics world settings
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
    }
    
    func submitHighScore(name:String, score:Int, index:Int){
        if name == ""{
            let name = "No Name Provided"
            hsScoreArray.insert(score, at: index)
            hsScoreArray.removeLast()
            UserDefaults.standard.set(hsScoreArray, forKey: "hsScoreArray")
            hsNameArray.insert(name, at:index)
            hsNameArray.removeLast()
            UserDefaults.standard.set(hsNameArray, forKey: "hsNameArray")
        }else{
            hsScoreArray.insert(score, at: index)
            hsScoreArray.removeLast()
            UserDefaults.standard.set(hsScoreArray, forKey: "hsScoreArray")
            hsNameArray.insert(name, at:index)
            hsNameArray.removeLast()
            UserDefaults.standard.set(hsNameArray, forKey: "hsNameArray")
        }
    }
    
    
}


// MARK: - functions dealing with screen touches
extension GameScene{
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else{
            return
        }
        spaceShip.position.x = touch.location(in: self).x
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        spaceShip.position.x = touch.location(in: self).x
    }
}


// MARK: - functions for game start/stop/pause
extension GameScene{
    func startGame(){
        if action(forKey: "lazer") == nil && gameActive == false{
            //isPaused = false
            run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addCube), SKAction.wait(forDuration: 1.0/Double(spawnRate!))])), withKey: "cube")
            
            run(SKAction.repeatForever(SKAction.sequence([SKAction.run(fireLazer), SKAction.wait(forDuration: 1.0/Double(fireRate!))])), withKey: "lazer")
        }
        action(forKey: "lazer")?.speed = 1
        action(forKey: "cube")?.speed = 1
        for child in children{
            if child.name == "lazer" || child.name == "cube"{
                child.isPaused = false
            }
        }
        isPaused = false
        run(SKAction.playSoundFileNamed("playorpause.mp3", waitForCompletion: false))
    }
    
    
    
    func restartGame(){
        health = UserDefaults.standard.integer(forKey: "health")
        cubesDestroyed = 0
        for child in children{
            if child.name == "lazer" || child.name == "cube"{
                child.removeFromParent()
            }
        }
        run(SKAction.playSoundFileNamed("newGameSound.mp3", waitForCompletion: false))
        removeAction(forKey: "lazer")
        removeAction(forKey: "cube")
        //isPaused = true
        action(forKey: "lazer")?.speed = 0
        action(forKey: "cube")?.speed = 0
        gameActive = false
        
    }
    
    
    
    func pauseGame(){
        //isPaused = true
        action(forKey: "lazer")?.speed = 0
        action(forKey: "cube")?.speed = 0
        for child in children{
            if child.name == "lazer" || child.name == "cube"{
                child.isPaused = true
            }
        }
        
        run(SKAction.playSoundFileNamed("playorpause.mp3", waitForCompletion: false))
    }
    
}



// MARK: - Collision Reactions
extension GameScene{
    func lazerCubeCollision(lazer: SKSpriteNode, cube: SKShapeNode){
        //print("hit")
        //print(cube.userData!["hp"] ?? 0)
        var flip = 0.0
        if cubesDestroyed % 2 == 0{
            flip = -1.0
        }else{
            flip = 1.0
        }
        cube.run(SKAction.rotate(byAngle: flip * 1.570796, duration: 0.2))
        cube.userData!.setValue((cube.userData!["hp"] as? Int ?? 0) - 1, forKey: "hp")
        //print(cube.userData!["hp"] ?? 0)
        if(cube.userData!["hp"] as? Int ?? 0) <= 0{
            cube.removeFromParent()
            cubesDestroyed += 1
            run(SKAction.playSoundFileNamed("destroySound", waitForCompletion: false))
        }
        lazer.removeFromParent()
    }
    
    
    
    func baseCubeCollision(base: SKShapeNode, cube: SKShapeNode){
        cube.removeFromParent()
        run(SKAction.playSoundFileNamed("destroySound.mp3", waitForCompletion: false))
        health -= 1
        if health <= 0 {
            hsIndex = 0
            while(hsIndex < 10 && hsScoreArray[hsIndex] > cubesDestroyed){
                hsIndex += 1
            }

            if(hsIndex != 10){
                gameVC?.showNewHSEntry()
                run(SKAction.playSoundFileNamed("funSong.mp3", waitForCompletion: false))
            }else{
                run(SKAction.playSoundFileNamed("slightlyLessFunSong.mp3", waitForCompletion: false))
            }
            
            highScore = cubesDestroyed
            restartGame()
            gameVC?.previousScoreLabelOutlet.text = String(highScore) + " Points!"
            gameVC?.previousScoreLabelOutlet.isHidden = false
        }
    }
}


// MARK: - Node Creation/Animation
extension GameScene{
    // Used for continually creating backgrounds (starting off screen)
    func loopSpaceBG(){
        var spaceBackground = SKSpriteNode()
        if bgImage {
            spaceBackground = SKSpriteNode(imageNamed: "spaceBackground2")
        }else{
            spaceBackground = SKSpriteNode(imageNamed: "spaceBackground")
        }
        bgImage = !bgImage
        let scale = size.width / spaceBackground.size.width
        spaceBackground.setScale(scale)
        spaceBackground.position = CGPoint(x: size.width/2, y: spaceBackground.size.height/2 + size.height + 100)
        spaceBackground.name = "spaceBackground"
        spaceBackground.zPosition = 0
        addChild(spaceBackground)
        
        let backgroundMove = SKAction.moveBy(x: 0, y: -spaceBackground.size.height - size.height - 200, duration: bgSpeed)
        let bgMoveDone = SKAction.removeFromParent()
        
        spaceBackground.run(SKAction.sequence([ backgroundMove, bgMoveDone]))
    }
    
    
    // Adds initial background (starting on screen)
    func addBackground(){
        let spaceBackground = SKSpriteNode(imageNamed: "spaceBackground")
        spaceBackground.position.x = size.width/2
        let scale = size.width / spaceBackground.size.width
        spaceBackground.setScale(scale)
        spaceBackground.position.y = spaceBackground.size.height/2
        spaceBackground.name = "spaceBackground"
        spaceBackground.zPosition = 0
        addChild(spaceBackground)
    
        let backgroundMove = SKAction.moveBy(x: 0, y: -spaceBackground.size.height - size.height - 200, duration: bgSpeed)
        let bgMoveDone = SKAction.removeFromParent()
        
        spaceBackground.run(SKAction.sequence([ backgroundMove, bgMoveDone]))
    }
    
    
    // Spawns in cubes
    func addCube(){
        var cubeColor:UIColor = .blue//:String = ""
        if(randCubeColor == true){
            let x = Int.random(in: 0..<4)
            if x == 0{
                cubeColor = .red//"redCube"
            }else if x == 1{
                cubeColor = .yellow//"yellowCube"
            }else if x == 2{
                cubeColor = .green//"greenCube"
            }else if x == 3{
                cubeColor = .blue//"blueCube"
            }else{
                cubeColor = .blue//"blueCube"
            }
        }else{
            cubeColor = .blue//"blueCube"
        }
        
        let cubeDict:NSMutableDictionary = [:]
        cubeDict.setValue(cubeHealth, forKey: String("hp"))
        //SKSpriteNode(imageNamed: cubeColor)
        
        var scale = 0
        if randCubeScale == true{
            scale = Int.random(in: 25..<100)
            //cube.scale(to: CGSize(width: scale, height: scale))
            //cube.setScale(CGFloat(scale))
        }else{
            scale = 25
        }
        let cube = SKShapeNode(rectOf: CGSize(width: scale, height: scale))
        cube.fillColor = cubeColor
        cube.zPosition = 1
        cube.name = "cube"
        cube.userData = cubeDict
        cube.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: scale, height: scale))
        cube.physicsBody?.isDynamic = true
        cube.physicsBody?.categoryBitMask = PhysCat.cube
        cube.physicsBody?.contactTestBitMask = PhysCat.lazer & PhysCat.base
        cube.physicsBody?.collisionBitMask = PhysCat.none
        let posX = random(min: CGFloat(scale/2), max: size.width - CGFloat(scale/2))
        cube.position = CGPoint(x: posX, y: size.height - CGFloat(scale/2))
        addChild(cube)
        var cubeSpeedMin = CGFloat((cubeSpeed ?? 10.0) - (cubeSpeedVariance ?? 4.0))
        var cubeSpeedMax = CGFloat((cubeSpeed ?? 10.0) + (cubeSpeedVariance ?? 4.0))
        if cubeSpeedMax > 20.0{
            cubeSpeedMax = 20.0
        }
        if cubeSpeedMin < 0.1{
            cubeSpeedMin = 0.1
        }
        
        let duration = random(min: cubeSpeedMin, max: cubeSpeedMax)
        let cubeMove = SKAction.move(to: CGPoint(x: posX, y: -CGFloat(scale/2)), duration: TimeInterval(duration))
        let cubeMoveDone = SKAction.removeFromParent()
        
        cube.run(SKAction.sequence([cubeMove, cubeMoveDone]))
    }
    
    
    // Creates space ship lazers
    func fireLazer(){
        let lazer = SKSpriteNode(imageNamed: "lazer")
        lazer.position = CGPoint(x: spaceShip.position.x, y: spaceShip.position.y + 35.0)
        lazer.zPosition = 1
        lazer.name = "lazer"
        lazer.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:5.0,height:25.0))
        lazer.physicsBody?.isDynamic = true
        lazer.physicsBody?.categoryBitMask = PhysCat.lazer
        lazer.physicsBody?.contactTestBitMask = PhysCat.cube
        lazer.physicsBody?.collisionBitMask = PhysCat.none
        lazer.physicsBody?.usesPreciseCollisionDetection = true
        addChild(lazer)

        let lazerMove = SKAction.moveBy(x:0, y:size.height ,duration: 2.5)
        let lazerMoveDone = SKAction.removeFromParent()
        //run(SKAction.playSoundFileNamed("lazerSound.mp3", waitForCompletion: false))
        //var sound = SKAction.playSoundFileNamed("lazerSound.mp3", waitForCompletion: false)
        let sound = SKAudioNode(fileNamed: "lazerSound.mp3")
        sound.autoplayLooped = false
        addChild(sound)
        //sound.run(SKAction.play())
        sound.run(SKAction.sequence([SKAction.changeVolume(to: 0.5, duration: 0.0), SKAction.play(), SKAction.wait(forDuration: 2.0), lazerMoveDone]))
        
        //playSound(soundVar: soundFile)
        
        lazer.run(SKAction.sequence([lazerMove, lazerMoveDone]))
    }
    
//    //func playSound(soundVar : SKAction){
//        run(soundVar)
//    }
    
    
}


// MARK: - Utility Functions
extension GameScene{
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
}



// MARK: - collision detection
extension GameScene: SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysCat.cube != 0) && (secondBody.categoryBitMask & PhysCat.lazer != 0)){
            if let cube = firstBody.node as? SKShapeNode, let lazer = secondBody.node as? SKSpriteNode {
                lazerCubeCollision(lazer: lazer, cube: cube)
            }
        }
        
        if((firstBody.categoryBitMask & PhysCat.cube != 0) && (secondBody.categoryBitMask & PhysCat.base != 0)){
            if let cube = firstBody.node as? SKShapeNode, let base = secondBody.node as? SKShapeNode {
                baseCubeCollision(base: base, cube: cube)
            }
        }
    }
}
