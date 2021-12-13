//
//  GameScene.swift
//  testFrog
//
//  Created by suding on 2021/12/09.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
 
    var frog = SKSpriteNode()
    var moving: SKNode!
    
    override func didMove(to view: SKView) {
        moving = SKNode()
        createFrog()
        createEnvironment()
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        createForever(duration: 4)
    }
    
    // MARK: 개구리 만들기
    func createFrog() {
        frog = SKSpriteNode(imageNamed: "frog")
        //frog.position = CGPoint(x: self.size.width/2, y: 350)
        frog.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height / 2) // 어디서떨어지는지
        frog.setScale(0.3)
        frog.zPosition = 4
        
        
        frog.physicsBody = SKPhysicsBody(circleOfRadius: frog.size.height / 2)
        
        // 충돌
        frog.physicsBody?.categoryBitMask = PhysicsCategory.frog
        frog.physicsBody?.contactTestBitMask = PhysicsCategory.wallDown | PhysicsCategory.wallUp | PhysicsCategory.score
        
        // 이 3개의 요소 부딫히면 충돌효과있음
        frog.physicsBody?.collisionBitMask =  PhysicsCategory.wallDown | PhysicsCategory.wallUp | PhysicsCategory.land
        frog.physicsBody?.affectedByGravity = true
        frog.physicsBody?.isDynamic = true
        self.addChild(frog)
        print(frog.position)
        
    }
    
    // MARK: 배경화면 만들기
    func createEnvironment() {
        
        let environmentAtlas = SKTextureAtlas(named: "Environment")
        let landTexture = environmentAtlas.textureNamed("ground2")
        let landRepeatNum = Int(ceil(self.size.width / landTexture.size().width))
        
        
        for i in 0...landRepeatNum {
            let land = SKSpriteNode(texture: landTexture)
            land.anchorPoint = CGPoint.zero // anchorPoint 어디 기준으로 이미지를 붙힐지
            land.position = CGPoint(x: CGFloat(i) * land.size.width, y: 0)
        //   land.position = CGPoint(x: CGFloat(i), y: -(self.frame.size.height / 2) * 0.25)
            land.zPosition = 3
            land.physicsBody = SKPhysicsBody(rectangleOf: land.size , // land Size크기만큼의 물리 충돌 적용
                                             center: CGPoint(x: land.size.width / 2, y: land.size.height / 2))
            
            land.physicsBody?.categoryBitMask = PhysicsCategory.land
            land.physicsBody?.isDynamic = false
            land.physicsBody?.affectedByGravity = false
            addChild(land)
            
            let moveLeft = SKAction.moveBy(x: -landTexture.size().width, y: 0, duration: 20) // land size만큼 이동
            let moveReset = SKAction.moveBy(x: landTexture.size().width, y: 0, duration: 0)
            let moveSequence = SKAction.sequence([moveLeft, moveReset])
            land.run(SKAction.repeatForever(moveSequence))
            print(land.size.height)
        }
    
        let skyTexture = environmentAtlas.textureNamed("sky4")
        let skyRepeatNum = Int(ceil(self.size.width / skyTexture.size().width))
        
        for i in 0...skyRepeatNum {
            let sky = SKSpriteNode(texture: skyTexture)
            sky.anchorPoint = CGPoint.zero
            sky.position = CGPoint(x: CGFloat(i) * sky.size.width, y: 0)
            sky.zPosition = 1
            addChild(sky)
            
            let moveLeft = SKAction.moveBy(x: -skyTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: skyTexture.size().width, y: 0, duration: 0)
            let moveSequence = SKAction.sequence([moveLeft, moveReset])
            sky.run(SKAction.repeatForever(moveSequence))
        }
           
        
    }
    
    // MARK: 장애물 만들기
    func setupObstacle(wallDistance: CGFloat) {
        let environmentAtlas = SKTextureAtlas(named: "Environment")
        let obstacleTexture = environmentAtlas.textureNamed("obstacle")
        let downObstacleTexture = environmentAtlas.textureNamed("downObt")
        
        let obstacleUp = SKSpriteNode(texture: obstacleTexture)
        obstacleUp.zPosition = 2
        obstacleUp.physicsBody = SKPhysicsBody(rectangleOf: obstacleTexture.size())
        obstacleUp.physicsBody?.categoryBitMask = PhysicsCategory.wallUp
        obstacleUp.physicsBody?.isDynamic = false
        
        let obstacleDown = SKSpriteNode(texture: downObstacleTexture)
        obstacleDown.zPosition = 2
        obstacleDown.physicsBody = SKPhysicsBody(rectangleOf: obstacleTexture.size())
        obstacleDown.physicsBody?.categoryBitMask = PhysicsCategory.wallUp
        obstacleDown.physicsBody?.isDynamic = false
        
        let obstacleCollision = SKSpriteNode(color: UIColor.red, size: CGSize(width: 1, height: self.size.height))
        obstacleCollision.zPosition = 2
        obstacleCollision.physicsBody = SKPhysicsBody(rectangleOf: obstacleCollision.size)
        obstacleCollision.physicsBody?.categoryBitMask = PhysicsCategory.score
        obstacleCollision.physicsBody?.isDynamic = false
        obstacleCollision.name = "collision"
        
        addChild(obstacleUp)
        addChild(obstacleDown)
        addChild(obstacleCollision)
        
        let max = self.size.height * 0.3 // (화면의 높이의 30%)
        let xPos = self.size.width + obstacleUp.size.width
        let yPos = CGFloat(arc4random_uniform(UInt32(max))) + environmentAtlas.textureNamed("land").size().height
        let endPos = self.size.width + (obstacleDown.size.width * 2)
      //  obstacleDown.position = CGPoint(x: xPos, y: yPos)
      //  obstacleUp.position = CGPoint(x: xPos, y: obstacleDown.position.y + wallDistance + obstacleUp.size.height)
        obstacleUp.setScale(0.8)
        obstacleDown.setScale(0.8)
          obstacleUp.position = CGPoint(x: xPos, y: yPos)
          obstacleDown.position = CGPoint(x: xPos, y: obstacleDown.position.y + wallDistance + obstacleUp.size.height)
        obstacleCollision.position = CGPoint(x: xPos, y: self.size.height / 2)
        
         let moveAct = SKAction.moveBy(x: CGFloat(-endPos), y: 0, duration: 6)
        let moveSequence = SKAction.sequence([moveAct, SKAction.removeFromParent()])
        
        
        obstacleUp.run(moveSequence)
        obstacleDown.run(moveSequence)
        obstacleCollision.run(moveSequence)
    
        
    }
    
    
    // MARK: 무한으로 생겨나줘
    func createForever(duration: TimeInterval) {
        let create = SKAction.run { [unowned self] in
            self.setupObstacle(wallDistance: 450)
            
        }
        let wait = SKAction.wait(forDuration: duration)
        let actSeq = SKAction.sequence([create, wait])
        run(SKAction.repeatForever(actSeq))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    self.frog.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
   //     self.frog.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        
        if moving.speed > 0 {
            for _ in touches {
                frog.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                frog.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
                    }
                }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
    
        var collideBody = SKPhysicsBody() // frog가 아닌 다른 충돌 객체
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
          
            collideBody = contact.bodyB
            
        } else {
           
            collideBody = contact.bodyA
            
        }
        
        let collideType = collideBody.categoryBitMask
        switch collideType {
        case PhysicsCategory.land:
            print("land")
        case PhysicsCategory.wallUp:
            print("위에 장애물")
        case PhysicsCategory.wallDown:
            print("아래장애물")
        case PhysicsCategory.score:
            print("점수")
        default:
            break 
        }
    }
}
