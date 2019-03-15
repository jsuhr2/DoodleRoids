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
var numEnemies = 8

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
        static let Wall: UInt32 = 0b1
        static let None : UInt32 = 0
        static let Madden : UInt32 = 0b10 //1
        static let Blast : UInt32 = 0b100 //2
        static let Enemy : UInt32 = 0b1000 //3
        static let Platform: UInt32 = 0b10000
    }
    
    func randomPoint(scene: CGRect) -> CGPoint {
        let x = CGFloat(arc4random_uniform(UInt32(scene.width)))
        let y = CGFloat(arc4random_uniform(UInt32(scene.height)))
        return CGPoint(x: x, y: y)
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
        
        madden.setScale(2)
        madden.position = CGPoint(x: self.size.width/2, y: self.size.height/5)
        madden.zPosition = 2
        madden.physicsBody = SKPhysicsBody(rectangleOf: madden.size)
        madden.physicsBody!.affectedByGravity = true;
        madden.physicsBody!.allowsRotation = false;
        madden.physicsBody!.categoryBitMask = PhysicsCategories.Madden
        madden.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy | PhysicsCategories.Platform
        self.addChild(madden)
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.9)
        scoreLabel.zPosition = 3
        self.addChild(scoreLabel)
        
        let plat = SKSpriteNode(imageNamed: "platform2")
        plat.setScale(0.2)
        plat.position = CGPoint(x: self.size.width/2, y: 40)
        plat.zPosition = 1
        plat.physicsBody = SKPhysicsBody(rectangleOf: plat.size)
            //CGSize(width: plat.size.width, height: plat.size.height), center: plat.position)
        plat.physicsBody!.affectedByGravity = false;
        plat.physicsBody!.categoryBitMask = PhysicsCategories.Platform
        plat.physicsBody!.collisionBitMask = PhysicsCategories.None
        plat.physicsBody!.contactTestBitMask = PhysicsCategories.Madden
        self.addChild(plat)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
        borderBody.friction = 0
        borderBody.categoryBitMask = PhysicsCategories.Wall
        physicsBody = borderBody
        
        generatePlatforms()
        generateEnemies()
    }
    
    func generatePlatforms(){
        for _ in 1...6{
            let i = SKSpriteNode(imageNamed: "platform2")
            i.setScale(0.2)
            i.position = CGPoint(x: self.size.width*random(), y: self.size.width*random())
            i.zPosition = 1
            i.physicsBody = SKPhysicsBody(rectangleOf: i.size)
            //CGSize(width: plat.size.width, height: plat.size.height), center: plat.position)
            i.physicsBody!.affectedByGravity = false;
            i.physicsBody!.categoryBitMask = PhysicsCategories.Platform
            i.physicsBody!.collisionBitMask = PhysicsCategories.None
            i.physicsBody!.contactTestBitMask = PhysicsCategories.Madden
            self.addChild(i)
        }
    }
    
    func generateEnemies(){
        for _ in 1...numEnemies{
            let i = SKSpriteNode(imageNamed: "Android_Studio_icon")
            i.setScale(0.07)
            i.position = CGPoint(x: self.size.width*random(), y: (self.size.height/2*random())+self.size.height/2)
            i.zPosition = 2
            i.physicsBody = SKPhysicsBody(rectangleOf: i.size)
            i.physicsBody!.affectedByGravity = false;
            i.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
            i.physicsBody!.contactTestBitMask = PhysicsCategories.Madden
            
            i.physicsBody?.restitution = 1
            i.physicsBody?.friction = 0
            i.physicsBody?.collisionBitMask = PhysicsCategories.Wall
            i.physicsBody?.collisionBitMask |= PhysicsCategories.Platform
            i.physicsBody?.affectedByGravity = false
            i.physicsBody?.angularDamping = 0
            i.physicsBody?.linearDamping = 0
            
            self.addChild(i)
            
            i.physicsBody!.applyImpulse((CGVector(dx: random()+5, dy: random()+5)))
        }
    }
    
    func increaseScore(){
        score += 1
        scoreLabel.text = "Score: \(score)"
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
        } else if (num1.categoryBitMask == PhysicsCategories.Madden && num2.categoryBitMask == PhysicsCategories.Platform){
            num1.applyImpulse(CGVector(dx: 0, dy: 100))
        } else if num2.node != nil{
            if(num1.categoryBitMask == PhysicsCategories.Blast && num2.categoryBitMask == PhysicsCategories.Enemy){
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
    
    func changeOverScene(){
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        let sceneMoveTo = GameOverScene(size: self.size)
        self.view?.presentScene(sceneMoveTo, transition: transition)
    }
    
    func changeWinScene(){
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        let sceneMoveTo = GameWinScene(size: self.size)
        self.view?.presentScene(sceneMoveTo, transition: transition)
    }
    
    func end(){
        self.removeAllActions()
        changeOverScene()
    }
    
    override func didSimulatePhysics() {
        if madden.position.y < 0 {
            end()
        }
        if(score == numEnemies){
            changeWinScene()
        }
        
        let dy = madden.physicsBody!.velocity.dy
        let z = CGFloat(0)
        if dy > z {
            // Prevent collisions if the hero is jumping
            madden.physicsBody!.collisionBitMask &= ~PhysicsCategories.Platform
        }
        else {
            // Allow collisions if the hero is falling
            madden.physicsBody!.collisionBitMask &= ~PhysicsCategories.Wall
            madden.physicsBody!.collisionBitMask |= PhysicsCategories.Platform
        }
        return;
    }
    
    func fire(location: CGPoint){
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
        
        let moveBlast = SKAction.move(to: location, duration: 0.5)
        let deleteBlast = SKAction.removeFromParent()
        let blastSequence = SKAction.sequence([moveBlast, deleteBlast])
        blast.run(blastSequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        fire(location: location)
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
