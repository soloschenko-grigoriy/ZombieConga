//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Gregory Soloshchenko on 7/16/17.
//  Copyright © 2017 GSClasses. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "MainMenu")
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(bg)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {
            return
        }
        
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        
        let transition = SKTransition.doorway(withDuration: 0.5)
        
        view?.presentScene(scene, transition: transition)
    }
    
}
