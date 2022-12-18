//
//  OptionsVC.swift
//  MatchEmScene
//
//  Created by Patrick Rode on 10/10/22.
//

import UIKit

class OptionsVC: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let destination = segue.destination
        
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

class GameOptions{
    
    let rectSizeMin:CGFloat = 50.0
    let rectSizeMax:CGFloat = 150.0
    //rectangle opacity
    var randomAlpha = false
    // how long for the rectangle to fade
    var fadeDuration: TimeInterval = 0.8
    // rectangle creation interval
    var spawnInterval: TimeInterval = 1.0

    // game duration
    var gameDuration: TimeInterval = 12.0
    
    init(gameDuration: TimeInterval, spawnInterval: TimeInterval){
        self.gameDuration = gameDuration
        self.spawnInterval = spawnInterval
    }
    
}
