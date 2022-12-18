//
//  Utility.swift
//  MatchEmScene
//
//  Created by Patrick Rode on 10/9/22.
//

import Foundation
import UIKit

class Utility: NSObject{
    
    
    //MARK: - ==== Random Value Funcs ====
    
    //================================================================
    static func randomFloatZeroThroughOne() -> CGFloat{
        //get a random value
        let randomFloat = CGFloat.random(in: 0...1.0)
        
        return randomFloat
    }
    
    //================================================================
    static func getRandomSize(fromMin min: CGFloat, throughMax max: CGFloat) -> CGSize {
        //create a random CGSize
        let randWidth = randomFloatZeroThroughOne() * (max - min) + min
        let randHeight = randomFloatZeroThroughOne() * (max - min) + min
        let randSize = CGSize(width: randWidth, height: randHeight)
        
        return randSize
    }
    
    //================================================================
    static func getRandomLocation(size rectSize: CGSize, screenSize: CGSize) -> CGPoint {
        //get the screen dimensions
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        //create a random location
        let rectX = randomFloatZeroThroughOne() * (screenWidth - rectSize.width)
        let rectY = randomFloatZeroThroughOne() * (screenHeight - rectSize.height)
        let location = CGPoint(x: rectX, y: rectY)
        
        return location
    }
    
    //================================================================
    static func getRandomColor(randomAlpha: Bool) -> UIColor {
        //get random vals for rgb
        let randRed = randomFloatZeroThroughOne()
        let randGreen = randomFloatZeroThroughOne()
        let randBlue = randomFloatZeroThroughOne()
        
        // transparency can be none or rand
        var alpha:CGFloat = 1.0
        if randomAlpha {
            alpha = randomFloatZeroThroughOne()
        }
        
        return UIColor(red: randRed, green: randGreen, blue: randBlue, alpha: alpha)
    }
}
