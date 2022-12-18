//
//  ViewController.swift
//  CubeDestroyer
//
//  Created by Patrick Rode on 12/15/22.
//

import UIKit
import SpriteKit

class GameVC: UIViewController {
    
    var scene = GameScene()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scene.gameVC = self
        scene.size = view.bounds.size //= GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = false
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        restartButtonOutlet.isHidden = true
        restartButtonOutlet.isEnabled = false
        
        hideNewHSEntry()
        previousScoreLabelOutlet.isHidden = true
        
        scoreLabelOutlet.text = "Score\n" + String(scene.cubesDestroyed)
        healthLabelOutlet.text = "Health\n" + String(scene.health)
        
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let configVC = segue.destination as? ConfigVC
        configVC?.gameVC = self
    }

    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func showNewHSEntry(){
        
        hsNameOutlet.isHidden = false
        hsNameOutlet.isEnabled = true
        
        hsLableOutlet.isHidden = false
        
        hsSubmitOutlet.isHidden = false
        hsSubmitOutlet.isEnabled = true
    }
    
    func hideNewHSEntry(){
        
        hsNameOutlet.isHidden = true
        hsNameOutlet.isEnabled = false
        
        hsLableOutlet.isHidden = true
        
        hsSubmitOutlet.isHidden = true
        hsSubmitOutlet.isEnabled = false
    }
    
    
    @IBAction func playButtonAction(_ sender: Any) {
        
        if scene.gameActive == true{
            scene.pauseGame()
            restartButtonOutlet.isHidden = false
            restartButtonOutlet.isEnabled = true
            
        }else{
            scene.startGame()
            restartButtonOutlet.isHidden = true
            restartButtonOutlet.isEnabled = false
        }
        hideNewHSEntry()
        previousScoreLabelOutlet.isHidden = true
        scene.gameActive = !scene.gameActive
    }
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    
    @IBAction func restartButtonAction(_ sender: Any) {
        scene.restartGame()
        restartButtonOutlet.isHidden = true
        restartButtonOutlet.isEnabled = false
        scene.gameActive = false
        previousScoreLabelOutlet.isHidden = true
    }
    @IBOutlet weak var restartButtonOutlet: UIButton!
    
    
    @IBOutlet weak var healthLabelOutlet: UILabel!
    
    @IBOutlet weak var scoreLabelOutlet: UILabel!
    
    
    @IBOutlet weak var hsLableOutlet: UILabel!
    
    @IBAction func hsSubmitAction(_ sender: Any) {
        scene.submitHighScore(name: hsNameOutlet.text ?? "None", score: scene.highScore, index: scene.hsIndex)
        hideNewHSEntry()
        hsNameOutlet.text = ""
    }
    @IBOutlet weak var hsSubmitOutlet: UIButton!
    
    @IBAction func hsNameAction(_ sender: Any) {
        //scene.submitHighScore(name: hsNameOutlet.text ?? "None", score: scene.cubesDestroyed, index: scene.hsIndex)
        //hideNewHSEntry()
        //hsNameOutlet.text = ""
    }
    @IBOutlet weak var hsNameOutlet: UITextField!
    
    
    @IBOutlet weak var previousScoreLabelOutlet: UILabel!
    
}

