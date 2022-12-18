//
//  GameScene.swift
//  CubeDestroyer
//
//  Created by Patrick Rode on 12/15/22.
//

import SpriteKit



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

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}


class GameScene: SKScene{
    
    
    
    
    
    
    // Config Items
    var health = 50{
        didSet{
            gameVC?.healthLabelOutlet.text! = "Health\n" + String(health)
        }
    }
    var fireRate:Int?
    var spawnRate:Int?
    var cubeScale:CGSize?// = CGSize(width: 75, height: 75)
    var randCubeScale:Bool?
    var randCubeColor:Bool?
    var cubeHealth:Int?
    //var cubeNumber:Int?
    //var cubeDict:NSMutableDictionary = [:]
    
    
    
    
    
    
    
    // Bit Masks for physics engine collisions
    struct PhysCat{
        static let none:UInt32 = 0x00
        static let all:UInt32 = UInt32.max
        static let cube:UInt32 = 0b1
        static let lazer:UInt32 = 0b10
        static let base:UInt32 = 0b100
    }
    var gameVC:GameVC?
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
    let spaceShip = SKSpriteNode(imageNamed: "spaceShip")
    
    let spaceShipMoveRight = SKAction.repeatForever(SKAction.moveBy(x:1, y:0, duration: 0.01))
    let spaceShipMoveLeft = SKAction.repeatForever(SKAction.moveBy(x:-1, y:0, duration: 0.01))
    var base = SKShapeNode()
    var cubesDestroyed = 0{
        didSet{
            gameVC?.scoreLabelOutlet.text! = "Score\n" + String(cubesDestroyed)
        }
    }
    
    
    override func didMove(to view: SKView){
        //loading stuff from userdefaults
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
        
        
        
        
        
        
        

        backgroundColor = .white
        
        spaceShip.scale(to: CGSize(width: 50, height: 50) )
        spaceShip.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        addChild(spaceShip)
        
        

        base.removeFromParent()
        base = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: size.height * 0.15), size: CGSize(width: size.width, height: size.height * 0.05)))
        base.fillColor = .systemBlue
        base.alpha = 0.5
        addChild(base)
        base.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: size.height * 0.2), to: CGPoint(x: size.width, y: size.height * 0.2))
        base.physicsBody?.isDynamic = true
        base.physicsBody?.categoryBitMask = PhysCat.base
        base.physicsBody?.contactTestBitMask = PhysCat.cube
        base.physicsBody?.collisionBitMask = PhysCat.none
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        
        
    }
    
    func startGame(){
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addCube), SKAction.wait(forDuration: 1.0/Double(spawnRate!))])))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(fireLazer), SKAction.wait(forDuration: 1.0/Double(fireRate!))])))
        
        for child in children{
            child.isPaused = false
        }
    }
    
    func restartGame(){
        health = UserDefaults.standard.integer(forKey: "health")
        cubesDestroyed = 0
        for child in children{
            if child.name == "lazer" || child.name == "cube"{
                child.removeFromParent()
            }
        }
        removeAllActions()
        gameActive = false
        //gameVC?.restartButtonOutlet.isHidden = true

    }
    
    func pauseGame(){
        removeAllActions()
        for child in children{

            child.isPaused = true
        }
        
    }
    
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
    
    func addCube(){
        var cubeColor:String = ""
        if(randCubeColor == true){
            let x = Int.random(in: 0..<4)
            if x == 0{
                cubeColor = "redCube"
            }else if x == 1{
                cubeColor = "yellowCube"
            }else if x == 2{
                cubeColor = "greenCube"
            }else if x == 3{
                cubeColor = "blueCube"
            }else{
                cubeColor = "blueCube"
            }
        }else{
            cubeColor = "blueCube"
        }
        
        
        let cubeDict:NSMutableDictionary = [:]
        //cubeNumber! += 1
        cubeDict.setValue(cubeHealth, forKey: String("hp"))
        let cube = SKSpriteNode(imageNamed: cubeColor)
        if randCubeScale == true{
            let scale = Int.random(in: 25..<100)
            cube.scale(to: CGSize(width: scale, height: scale))
        }
        cube.name = "cube"
        cube.userData = cubeDict
        cube.physicsBody = SKPhysicsBody(rectangleOf: cube.size)
        cube.physicsBody?.isDynamic = true
        cube.physicsBody?.categoryBitMask = PhysCat.cube
        cube.physicsBody?.contactTestBitMask = PhysCat.lazer & PhysCat.base
        cube.physicsBody?.collisionBitMask = PhysCat.none
        
        let posX = random(min: cube.size.width/2, max: size.width - cube.size.width/2)
        cube.position = CGPoint(x: posX, y: size.height - cube.size.height/2)
        addChild(cube)
        
        let duration = random(min: CGFloat(1.0), max: CGFloat(10.0))
        let cubeMove = SKAction.move(to: CGPoint(x: posX, y: -cube.size.height/2), duration: TimeInterval(duration))
        let cubeMoveDone = SKAction.removeFromParent()
        
        cube.run(SKAction.sequence([cubeMove, cubeMoveDone]))
    }
    
    func fireLazer(){
        let lazer = SKSpriteNode(imageNamed: "lazer")
        lazer.position = CGPoint(x: spaceShip.position.x, y: spaceShip.position.y + 35.0)
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
        lazer.run(SKAction.sequence([lazerMove, lazerMoveDone]))
        
    }
    
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
    
    
    func lazerCubeCollision(lazer: SKSpriteNode, cube: SKSpriteNode){
        //print("hit")
        //print(cube.userData!["hp"] ?? 0)
        cube.userData!.setValue((cube.userData!["hp"] as? Int ?? 0) - 1, forKey: "hp")
        //print(cube.userData!["hp"] ?? 0)
        if(cube.userData!["hp"] as? Int ?? 0) <= 0{
            cube.removeFromParent()
            cubesDestroyed += 1
        }
        lazer.removeFromParent()
        
        
        
        
    }
    
    func baseCubeCollision(base: SKShapeNode, cube: SKSpriteNode){
        cube.removeFromParent()
        
        health -= 1
        if health <= 0 {
            hsIndex = 0
            while(hsScoreArray[hsIndex] > cubesDestroyed && hsIndex < 10){
                hsIndex += 1
            }
            //print(hsScoreArray)
            if(hsIndex != 10){
                gameVC?.showNewHSEntry()
                print("high Score Detected")
                
            }
            highScore = cubesDestroyed
            //print(hsScoreArray)
            
            
            restartGame()
            gameVC?.previousScoreLabelOutlet.text = String(highScore) + " Points!"
            gameVC?.previousScoreLabelOutlet.isHidden = false
            
        }
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
            if let cube = firstBody.node as? SKSpriteNode, let lazer = secondBody.node as? SKSpriteNode {
                lazerCubeCollision(lazer: lazer, cube: cube)
            }
        }
        
        if((firstBody.categoryBitMask & PhysCat.cube != 0) && (secondBody.categoryBitMask & PhysCat.base != 0)){
            if let cube = firstBody.node as? SKSpriteNode, let base = secondBody.node as? SKShapeNode {
                baseCubeCollision(base: base, cube: cube)
            }
        }
    }
}
