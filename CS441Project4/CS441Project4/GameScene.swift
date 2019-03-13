//
//  GameScene.swift
//  CS441Project4
//
//  Created by Jasper Suhr on 3/4/19.
//  Copyright © 2019 Jasper Suhr. All rights reserved.
//

import SpriteKit
import GameplayKit

var score = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    let madden = SKSpriteNode(imageNamed: "Madden_Glasses_1")
    let scoreLabel = SKLabelNode()
    
    let gameArea: CGRect
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min:CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Madden : UInt32 = 0b1 //1
        static let Blast : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //3
        static let Platform: UInt32 = 0b1000
    }
    
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        score = 0
        
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "cs")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        backgroundColor = SKColor.white
        madden.setScale(2)
        madden.position = CGPoint(x: self.size.width/2, y: self.size.height/5)
        madden.zPosition = 2
        madden.physicsBody = SKPhysicsBody(rectangleOf: madden.size)
        madden.physicsBody!.affectedByGravity = false
        madden.physicsBody!.categoryBitMask = PhysicsCategories.Madden
        madden.physicsBody!.collisionBitMask = PhysicsCategories.None
        madden.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(madden)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        start()
    }
    
    func increaseScore(){
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
    func goToGameScene(){
        let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
        let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
        gameScene.scaleMode = SKSceneScaleMode.fill
        self.view!.presentScene(gameScene, transition: transition)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var num1 = SKPhysicsBody()
        var num2 = SKPhysicsBody()
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            num1 = contact.bodyA
            num2 = contact.bodyB
        }else{
            num1 = contact.bodyB
            num2 = contact.bodyA
        }
        if(num1.categoryBitMask == PhysicsCategories.Madden && num2.categoryBitMask == PhysicsCategories.Enemy){
            if(num1.node != nil){
                explode(spawnPosition: num1.node!.position)
            }
            if(num2.node != nil){
                explode(spawnPosition: num2.node!.position)
            }
            num1.node?.removeFromParent()
            num2.node?.removeFromParent()
            end()
        } else if num2.node != nil{
            if(num1.categoryBitMask == PhysicsCategories.Blast && num2.categoryBitMask == PhysicsCategories.Enemy && (num2.node?.position.y)! < self.size.height){
                explode(spawnPosition: num2.node!.position)
                num1.node?.removeFromParent()
                num2.node?.removeFromParent()
                increaseScore()
            }
        }
    }
    
    func explode(spawnPosition: CGPoint){
        let e = SKSpriteNode(imageNamed: "explosion")
        e.position = spawnPosition
        e.zPosition = 3
        e.setScale(0)
        self.addChild(e)
        
        let scaleIn = SKAction.scale(to: 0.1, duration: 0.1)
        let fade = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fade, delete])
        e.run(explosionSequence)
    }
    
    func start(){
        /*
        let spawn = SKAction.run(spawnEnemy)
        let wait = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([wait, spawn])
        let spawnContinuous = SKAction.repeatForever(spawnSequence)
        self.run(spawnContinuous)
        */
    }
    
    func end(){
        self.removeAllActions()
    }
/*
    func changeScene(){
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        let sceneMoveTo = GameOverScene(size: self.size)
        self.view?.presentScene(sceneMoveTo, transition: transition)
    }
*/
    func spawnEnemy(){
        
    }
    
    func fire(){
        let blast = SKSpriteNode(imageNamed: "apple")
        blast.setScale(0.023)
        blast.position = madden.position
        blast.zPosition = 1
        blast.physicsBody = SKPhysicsBody(rectangleOf: blast.size)
        blast.physicsBody!.affectedByGravity = false
        blast.physicsBody!.categoryBitMask = PhysicsCategories.Blast
        blast.physicsBody!.collisionBitMask = PhysicsCategories.None
        blast.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(blast)
        
        let moveBlast = SKAction.moveTo(y: self.size.height+blast.size.height, duration: 1)
        let deleteBlast = SKAction.removeFromParent()
        let blastSequence = SKAction.sequence([moveBlast, deleteBlast])
        blast.run(blastSequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fire()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let horizontalDragged = pointOfTouch.x - previousPointOfTouch.x
            madden.position.x += horizontalDragged
            
            if madden.position.x > gameArea.maxX - madden.size.width/2{
                madden.position.x = gameArea.maxX - madden.size.width/2
            }
            if madden.position.x < gameArea.minX + madden.size.width/2{
                madden.position.x = gameArea.minX + madden.size.width/2
            }
        }
    }

}
