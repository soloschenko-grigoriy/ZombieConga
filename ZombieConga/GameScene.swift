//
//  GameScene.swift
//  ZombieConga
//
//  Created by Gregory Soloshchenko on 7/14/17.
//  Copyright © 2017 GSClasses. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK Properties
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    let zombieMovePointsPerSecond: CGFloat = 480.0
    let zombieRotatePerSecond: CGFloat = 4.0 * π
    var velocity: CGPoint = .zero
    var zombieIsVisible = true

    var lastUpdatetTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let playbleRect: CGRect
    
    var lastTouchLocation: CGPoint?
    
    let zombieAnimation: SKAction
    let catCollisionSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    let catMovePointsPerSecond: CGFloat = 480.0
    
    var lives = 5
    var cats = 0
    var gameOver = false
    
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSecond: CGFloat = 200.0
    var cameraRect: CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playbleRect.width)/2
        let y = cameraNode.position.y - size.height/2 + (size.height - playbleRect.height)/2
        
        return CGRect(
            x: x,
            y: y,
            width: playbleRect.width,
            height: playbleRect.height
        )
    }
    
    let liveLabel = SKLabelNode(fontNamed: "Glimstick")
    let catLabel = SKLabelNode(fontNamed: "Glimstick")
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playbleHeight = size.width / maxAspectRatio
        let playbleMargin = (size.height - playbleHeight) / 2.0
        playbleRect = CGRect(x: 0, y: playbleMargin, width: size.width, height: playbleHeight)
        
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        playBgMusic(filename: "backgroundMusic.mp3")
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.zPosition = -1
            background.name = "background"
            addChild(background)
        }
        
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        addChild(zombie)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in
            self?.spawnEnemy()
        }, SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in
            self?.spawnCat()
        },
        SKAction.wait(forDuration: 1.0)])))
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position  = CGPoint(x: size.width/2, y: size.height/2)
        
        liveLabel.fontColor = SKColor.black
        liveLabel.fontSize = 100
        liveLabel.zPosition = 150
        liveLabel.horizontalAlignmentMode = .left
        liveLabel.verticalAlignmentMode = .bottom
        liveLabel.position = CGPoint(
            x: -playbleRect.size.width/2 + CGFloat(20),
            y: -playbleRect.size.height/2 + CGFloat(20)
        )
        
        cameraNode.addChild(liveLabel)
        
        
        catLabel.fontColor = SKColor.black
        catLabel.fontSize = 100
        catLabel.zPosition = 150
        catLabel.horizontalAlignmentMode = .right
        catLabel.verticalAlignmentMode = .bottom
        catLabel.position = CGPoint(
            x: playbleRect.size.width/2 - CGFloat(20),
            y: -playbleRect.size.height/2 + CGFloat(20)
        )
        
        cameraNode.addChild(catLabel)

    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdatetTime > 0 {
            dt = currentTime - lastUpdatetTime
        }
        lastUpdatetTime = currentTime
        moveCamera()
        
        move(sprite: zombie, with: velocity)
        rotate(sprite: zombie, in: velocity, by: zombieRotatePerSecond)

        checkBounds(for: zombie)
        moveTrain()
        
       
        if lives <= 0 && !gameOver {
            gameOver = true
            print("Game over!")
            backgroundMusicPlayer.stop()
            
            let scene = GameOverScene(size: size, won: false)
            scene.scaleMode = scaleMode
            
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)

            view?.presentScene(scene, transition: transition)
        }
        
        liveLabel.text = "Lives: \(lives)"
        catLabel.text = "Cats: \(cats)"
    }
    
    override func didEvaluateActions() {
        checkCollision()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        lastTouchLocation = location
        screenTouched(at: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        lastTouchLocation = location
        screenTouched(at: location)
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = .zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = .zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
        
        return backgroundNode
    }
    
    func startZombieAnmation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        
        let randomY = CGFloat.random(
            min: cameraRect.minY + enemy.size.height/2,
            max: cameraRect.maxY - enemy.size.height/2
        )
        
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width/2, y: randomY)
        enemy.zPosition = 51
        
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(x: cameraRect.minX - enemy.size.width/2, duration: 3.0)
        //        (x: -enemy.size.width/2, duration: 3.0)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([actionMove, removeFromParent])
        enemy.run(sequence)
        
    }
    
    func needToMove() -> Bool {
        guard let lastTouchLocation = lastTouchLocation else {
            return false
        }
        
        let offset = lastTouchLocation - zombie.position
        
        if offset.length() > zombieMovePointsPerSecond * CGFloat(dt) {
            return true
        }
        
        return false
    }
    
    func screenTouched (at location: CGPoint) {
        moveZombie(toward: location)
    }
    
    func move(sprite sp: SKSpriteNode, with velocity: CGPoint){
        let amoutToMove = velocity * CGFloat(dt)
        sp.position += amoutToMove
    }
    
    func moveZombie(toward location: CGPoint){
        startZombieAnmation()
        
        let offset = location - zombie.position

        velocity = offset.normalized() * zombieMovePointsPerSecond
    }
    
    func checkBounds(for sprite: SKSpriteNode){
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        if sprite.position.x <= bottomLeft.x {
            sprite.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        if sprite.position.y <= bottomLeft.y {
            sprite.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if sprite.position.x >= topRight.x {
            sprite.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if sprite.position.y >= topRight.y {
            sprite.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotate(sprite sp: SKSpriteNode, in direction: CGPoint, by radiansPerSecond: CGFloat){
        let shortest = getShortestAngleBetween(oneAngle: sp.zRotation, otherAngle: direction.angle)
        let amountToRotate = min(radiansPerSecond * CGFloat(dt), abs(shortest))
        sp.zRotation += shortest.sign() * amountToRotate
        
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX, max: cameraRect.maxX),
            y: CGFloat.random(min: cameraRect.minY, max: cameraRect.maxY)
        )
        
        cat.setScale(0)
        cat.zRotation = -π / 16.0
        cat.zPosition = 50
        
        addChild(cat)
        
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWigle = leftWiggle.reversed()
        let wigle = SKAction.sequence([leftWiggle, rightWigle])
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let scale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        
        let group = SKAction.group([wigle, scale])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let sequence = SKAction.sequence([
            SKAction.scale(to: 1, duration: 0.5),
            groupWait,
            SKAction.scale(to: 0, duration: 0.5),
            SKAction.removeFromParent()
        ])
        
        cat.run(sequence)
    }
    
    func zombieHit(cat: SKSpriteNode) {
        cat.name = "train"
        cat.setScale(1.0)
        cat.zRotation = 0
        cat.removeAllActions()
        
        cat.run(SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.2))
        
        run(catCollisionSound)
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        zombie.isHidden = true
        zombieIsVisible = false
        run(enemyCollisionSound)
        
        loseCats()
        lives -= 1
        
        let blinkTimes = 10.0
        let blinkDurarion = 3.0
        let blinkAction = SKAction.customAction(withDuration: blinkDurarion, actionBlock: { (node, elapsedTime) in
            let blinkSlice = blinkDurarion / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: blinkSlice)
            node.isHidden = remainder > blinkSlice / 2
        })
        
        let getBackZombie = SKAction.run({ [weak self] in
            self?.zombie.isHidden = false
            self?.zombieIsVisible = true
        })
        
        zombie.run(SKAction.sequence([blinkAction, getBackZombie]))
        
    }
    
    func checkCollision() {
        if(zombieIsVisible == false){
            return
        }
        
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if enemy.frame.insetBy(dx: 40, dy: 40).intersects(self.zombie.frame){
                hitEnemies.append(enemy)
            }
        }
        
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }
    
    func moveTrain() {
        var trainLength = 0
        var targetPosition = zombie.position
        enumerateChildNodes(withName: "train") { [weak self] node, stop in
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSecond = direction * (self?.catMovePointsPerSecond)!
                let amountToMove = amountToMovePerSecond * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
            trainLength += 1
        }
        
        cats = trainLength
        if trainLength >= 15 && !gameOver {
            gameOver = true
            print("You win!!")
            backgroundMusicPlayer.stop()
            
            let scene = GameOverScene(size: size, won: true)
            scene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(scene, transition:reveal)
        }
    }
    
    func loseCats() {
        var lostCats = 0
        enumerateChildNodes(withName: "train") { (node, stop) in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            node.name = ""
            node.run(SKAction.sequence([
                SKAction.group([
                    SKAction.rotate(byAngle: π*4, duration: 1.0),
                    SKAction.move(to: randomSpot, duration: 1.0),
                    SKAction.scale(to: 0, duration: 1.0)
                ]),
                SKAction.removeFromParent()
            ]))
            
            lostCats += 1
            if lostCats >= 2 {
                stop[0] = true
            }
            
        }
    }
    
    func moveCamera (){
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSecond, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { [weak self] (node, _) in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < (self?.cameraRect.origin.x)! {
                background.position = CGPoint(
                    x: background.position.x + background.size.width * 2,
                    y: background.position.y
                )
            }
        }
    }
    
    // MARK Private
    private func debugDrawPlaybleArea(){
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playbleRect)
        shape.path = path
        shape.strokeColor = .red
        shape.lineWidth = 4.0
        addChild(shape)
    }
}
