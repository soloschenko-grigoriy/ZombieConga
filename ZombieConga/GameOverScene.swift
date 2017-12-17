//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Gregory Soloshchenko on 7/16/17.
//  Copyright © 2017 GSClasses. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    var won: Bool
    
    init(size: CGSize, won: Bool) {
        self.won = won
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        var bg: SKSpriteNode
        var sound: String
        
        if won {
            bg = SKSpriteNode(imageNamed: "YouWin")
            sound = "win.wav"
        } else {
            bg = SKSpriteNode(imageNamed: "YouLose")
            sound = "lose.wav"
        }
        
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(bg)
        
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
        
        let wait = SKAction.wait(forDuration: 3.0)
        let block = SKAction.run { [weak self] _ in
            let scene = MainMenuScene(size: (self?.size)!)
            scene.scaleMode = (self?.scaleMode)!
            
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            
            self?.view?.presentScene(scene, transition: transition)
        }
        
        run(SKAction.sequence([wait, block]))
    }
    
    
}
