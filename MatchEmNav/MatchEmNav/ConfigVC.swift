//
//  ConfigVC.swift
//  MatchEmNav
//
//  Created by Patrick Rode on 12/13/22.
//

import UIKit

class ConfigVC: UIViewController {

    var gameSceneVC:GameSceneVC?
    let defaults = UserDefaults.standard
    
    
    @IBOutlet weak var spawnRateLabelOutlet: UILabel!
    @IBAction func spawnRateStepperAction(_ sender: UIStepper) {
        gameSceneVC?.options.spawnInterval = 1/spawnRateStepperOutlet.value
        spawnRateLabelOutlet.text = String(spawnRateStepperOutlet.value) + "/sec"
        defaults.set(gameSceneVC?.options.spawnInterval, forKey: "spawnInterval")
        changesNotificationLabelOutlet.isHidden = false
    }
    @IBOutlet weak var spawnRateStepperOutlet: UIStepper!
    
    
    @IBOutlet weak var gameDurationLabelOutlet: UILabel!
    @IBAction func gameDurationSliderAction(_ sender: UISlider) {
        gameSceneVC?.options.gameDuration = Double(floor(gameDurationSliderOutlet.value))
        gameDurationLabelOutlet.text = String(floor(gameDurationSliderOutlet.value)) + " seconds"
        defaults.set(gameSceneVC?.options.gameDuration, forKey: "gameDuration")
        changesNotificationLabelOutlet.isHidden = false
    }
    @IBOutlet weak var gameDurationSliderOutlet: UISlider!
    
    
    @IBAction func backgroundColorSegmentAction(_ sender: UISegmentedControl) {
        let colorIndex = backgroundColorSegmentOutlet.selectedSegmentIndex
        if colorIndex == 0{
            gameSceneVC?.options.backgroundColor = .white
        }else if colorIndex == 1{
            gameSceneVC?.options.backgroundColor = .black
        }else if colorIndex == 2{
            gameSceneVC?.options.backgroundColor = .red
        }else if colorIndex == 3{
            gameSceneVC?.options.backgroundColor = .green
        }else if colorIndex == 4{
            gameSceneVC?.options.backgroundColor = .blue
        }else{
            gameSceneVC?.options.backgroundColor = .white
        }
        
        defaults.set(colorIndex, forKey: "backgroundColor")
        changesNotificationLabelOutlet.isHidden = false
    }
    @IBOutlet weak var backgroundColorSegmentOutlet: UISegmentedControl!
    
    
    @IBAction func greyScaleModeSwitchAction(_ sender: UISwitch) {
        gameSceneVC?.options.greyScaleMode = greyScaleModeSwitchOutlet.isOn
        defaults.set(gameSceneVC?.options.greyScaleMode, forKey: "greyScaleMode")
        changesNotificationLabelOutlet.isHidden = false
    }
    @IBOutlet weak var greyScaleModeSwitchOutlet: UISwitch!
    
    
    @IBOutlet weak var highScoresLabelOutlet: UILabel!
    

    @IBOutlet weak var changesNotificationLabelOutlet: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool){
        spawnRateStepperOutlet.value = 1/(gameSceneVC?.options.spawnInterval)!
        spawnRateLabelOutlet.text = String(1/(gameSceneVC?.options.spawnInterval)!) + "/second"
        
        gameDurationSliderOutlet.value = Float((gameSceneVC?.options.gameDuration)!)
        gameDurationLabelOutlet.text = String((gameSceneVC?.options.gameDuration)!) + " seconds"
        
        let bgColor:UIColor = (gameSceneVC?.options.backgroundColor)!
        if(bgColor == .white){
            backgroundColorSegmentOutlet.selectedSegmentIndex = 0
        }else if bgColor == .black{
            backgroundColorSegmentOutlet.selectedSegmentIndex = 1
        }else if bgColor == .red{
            backgroundColorSegmentOutlet.selectedSegmentIndex = 2
        }else if bgColor == .green{
            backgroundColorSegmentOutlet.selectedSegmentIndex = 3
        }else if bgColor == .blue{
            backgroundColorSegmentOutlet.selectedSegmentIndex = 4
        }else{
            backgroundColorSegmentOutlet.selectedSegmentIndex = 0
        }
        
        greyScaleModeSwitchOutlet.isOn = (gameSceneVC?.options.greyScaleMode)!
        
        var hsString:String = "High Scores\n"
        for i in 0...2{
            hsString.append(String(i + 1) + ") ")
            hsString.append(String((gameSceneVC?.options.highScores[i])!) + "\n")
        }
//        for highScore in (gameSceneVC?.options.highScores)!{
//            hsString.append(String(highScore) + ", ")
//        }
        
        highScoresLabelOutlet.text = hsString
        
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
