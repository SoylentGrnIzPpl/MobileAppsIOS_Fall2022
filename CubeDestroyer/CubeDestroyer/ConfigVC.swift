//
//  ConfigVC.swift
//  CubeDestroyer
//
//  Created by Patrick Rode on 12/16/22.
//

import UIKit

class ConfigVC: UIViewController {
    
    var gameVC:GameVC?
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        if (gameVC?.scene.children.count)! > 2{
            disableOptions()
        }else{
            enableOptions()
        }
        //print(gameVC?.scene.children.count)
        super.viewDidLoad()
        healthStepperOutlet.value = Double(defaults.integer(forKey: "health"))
        fireRateSliderOutlet.value = Float(defaults.integer(forKey: "fireRate"))
        spawnRateSliderOutlet.value = Float(defaults.integer(forKey: "spawnRate"))
        randCubeSizeOutlet.isOn = Bool(defaults.bool(forKey: "randCubeScale"))
        randCubeColorOutlet.isOn = Bool(defaults.bool(forKey: "randCubeColor"))
        cubeHealthOutlet.selectedSegmentIndex = Int(defaults.integer(forKey: "cubeHealth")) - 1
        healthStepperLabel.text = String((gameVC?.scene.health)!) + "HP"
        fireRateLabel.text = String((gameVC?.scene.fireRate)!) + "/sec"
        spawnRateLabel.text = String((gameVC?.scene.spawnRate)!) + "/sec"
        
        
        //fireRateSliderOutlet.value = defaults.
       

        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func enableOptions(){
        healthStepperOutlet.isEnabled = true
        fireRateSliderOutlet.isEnabled = true
        spawnRateSliderOutlet.isEnabled = true
        randCubeSizeOutlet.isEnabled = true
        randCubeColorOutlet.isEnabled = true
        cubeHealthOutlet.isEnabled = true
        disabledOptionsNotificationLabel.isHidden = true
    }
    
    func disableOptions(){
        disabledOptionsNotificationLabel.isHidden = false
        healthStepperOutlet.isEnabled = false
        fireRateSliderOutlet.isEnabled = false
        spawnRateSliderOutlet.isEnabled = false
        randCubeSizeOutlet.isEnabled = false
        randCubeColorOutlet.isEnabled = false
        cubeHealthOutlet.isEnabled = false
    }
    
    
    @IBAction func healthStepperAction(_ sender: Any) {
        gameVC?.scene.health = Int(healthStepperOutlet.value)
        defaults.setValue(Int((gameVC?.scene.health)!), forKey: "health")
        healthStepperLabel.text = String((gameVC?.scene.health)!) + "HP"
    }
    @IBOutlet weak var healthStepperOutlet: UIStepper!
    
    @IBOutlet weak var healthStepperLabel: UILabel!
    
    @IBAction func fireRateSliderAction(_ sender: Any) {
        gameVC?.scene.fireRate = Int(fireRateSliderOutlet.value)
        defaults.setValue((gameVC?.scene.fireRate), forKey: "fireRate")
        fireRateLabel.text = String((gameVC?.scene.fireRate)!) + "/sec"
    }
    @IBOutlet weak var fireRateSliderOutlet: UISlider!
    
    
    @IBOutlet weak var fireRateLabel: UILabel!
    
    @IBAction func spawnRateSliderAction(_ sender: Any) {
        gameVC?.scene.spawnRate = Int(spawnRateSliderOutlet.value)
        defaults.setValue(gameVC?.scene.spawnRate, forKey: "spawnRate")
        spawnRateLabel.text = String((gameVC?.scene.spawnRate)!) + "/sec"
    }
    
    @IBOutlet weak var spawnRateSliderOutlet: UISlider!
    
    @IBOutlet weak var spawnRateLabel: UILabel!
    
    @IBAction func randCubeSizeAction(_ sender: Any) {
        gameVC?.scene.randCubeScale = Bool(randCubeSizeOutlet.isOn)
        defaults.setValue(gameVC?.scene.randCubeScale, forKey: "randCubeScale")
        
    }
    
    @IBOutlet weak var randCubeSizeOutlet: UISwitch!
    
    
    @IBAction func randCubeColorAction(_ sender: Any) {
        gameVC?.scene.randCubeColor = Bool(randCubeColorOutlet.isOn)
        defaults.setValue(gameVC?.scene.randCubeColor, forKey: "randCubeColor")
        
    }
    
    @IBOutlet weak var randCubeColorOutlet: UISwitch!
    
    @IBAction func cubeHealthAction(_ sender: Any) {
        gameVC?.scene.cubeHealth = Int(cubeHealthOutlet.selectedSegmentIndex + 1)
        defaults.setValue(Int((gameVC?.scene.cubeHealth)!), forKey: "cubeHealth")
        //cubeHealthOutlet.selectedSegmentIndex =
    }
    
    @IBOutlet weak var cubeHealthOutlet: UISegmentedControl!
    
    
    @IBAction func swipeRightAction(_ sender: UISwipeGestureRecognizer){
        if sender.state == .ended{
            if let navController = self.navigationController{
                navController.popViewController(animated: true)
            }
        }
    }

    
    @IBOutlet weak var disabledOptionsNotificationLabel: UILabel!
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
