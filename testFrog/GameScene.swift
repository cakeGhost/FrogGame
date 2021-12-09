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
    
    override func didMove(to view: SKView) {
        createFrog()
        createEnvironment()
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        createForever(duration: 4)
    }
    
    // MARK: 개구리 만들기
    func createFrog() {
        frog = SKSpriteNode(imageNamed: "frog")
        frog.position = CGPoint(x: self.size.width/2 - 100, y: 200)
        frog.setScale(0.4)
        frog.zPosition = 4
        frog.physicsBody = SKPhysicsBody(circleOfRadius: frog.size.height / 2)
        frog.physicsBody?.categoryBitMask = PhysicsCategory.frog
        frog.physicsBody?.contactTestBitMask = PhysicsCategory.land | PhysicsCategory.wallDown | PhysicsCategory.wallUp | PhysicsCategory.score
        frog.physicsBody?.collisionBitMask = PhysicsCategory.land | PhysicsCategory.wallDown | PhysicsCategory.wallUp // 부딫혔을 때의를 확인해야함
        frog.physicsBody?.affectedByGravity = true
        frog.physicsBody?.isDynamic = true
        self.addChild(frog)
        
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
            land.zPosition = 3
            land.physicsBody = SKPhysicsBody(rectangleOf: land.size, // land Size크기만큼의 물리 충돌 적용
                                             center: CGPoint(x: land.size.width / 2, y: land.size.height / 2))
            land.physicsBody?.categoryBitMask = PhysicsCategory.land
            land.physicsBody?.isDynamic = false // 부딫혀도 아무 효과없게 하기 위해 False
            land.physicsBody?.affectedByGravity = false // 중력에의해 계속 떨어지기 때문에 중력효과 없앰 
            addChild(land)
            
            let moveLeft = SKAction.moveBy(x: -landTexture.size().width, y: 0, duration: 20) // land size만큼 이동
            let moveReset = SKAction.moveBy(x: landTexture.size().width, y: 0, duration: 0)
            let moveSequence = SKAction.sequence([moveLeft, moveReset])
            land.run(SKAction.repeatForever(moveSequence))
        }
    
        let skyTexture = environmentAtlas.textureNamed("skymountain")
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
    
    
//
//    // MARK: 장애물 만들기
//    func createObstacle() {
//
//        let groundwall = SKSpriteNode(imageNamed: "obstacle")
//        groundwall.position = CGPoint(x: self.size.width/2,
//                                    y: self.size.height/7)
//        groundwall.zPosition = 2
//        groundwall.setScale(0.8)
//        self.addChild(groundwall)
//
//
//        let cellWall = SKSpriteNode(imageNamed: "downObt")
//        cellWall.position = CGPoint(x: self.size.width/2,
//                                    y: self.size.height * 0.8)
//        cellWall.zPosition = 2
//        cellWall.setScale(0.8)
//        self.addChild(cellWall)
//    }
    
    // MARK: 장애물 만들기
    func setupObstacle(wallDistance: CGFloat) {
        let environmentAtlas = SKTextureAtlas(named: "Environment")
        let obstacleTexture = environmentAtlas.textureNamed("obstacle")
        let downObstacleTexture = environmentAtlas.textureNamed("downObt")
        
        let obstacleUp = SKSpriteNode(texture: obstacleTexture)
        obstacleUp.zPosition = 2
        obstacleUp.physicsBody = SKPhysicsBody(rectangleOf: obstacleTexture.size())
        obstacleUp.physicsBody?.categoryBitMask = PhysicsCategory.wallUp
        obstacleUp.physicsBody?.isDynamic = false // 부딫혔을때 튕겨나가면 안됨
        
        let obstacleDown = SKSpriteNode(texture: downObstacleTexture)
        obstacleDown.zPosition = 2
        obstacleDown.physicsBody = SKPhysicsBody(rectangleOf: obstacleTexture.size())
        obstacleDown.physicsBody?.categoryBitMask = PhysicsCategory.wallDown
        obstacleDown.physicsBody?.isDynamic = false // 부딫혔을때 튕겨나가면 안됨
        
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
    
    
    // MARK: 무한으로 움직여줘
    func createForever(duration: TimeInterval) {
        let create = SKAction.run { [unowned self] in
            self.setupObstacle(wallDistance: 400)
            
        }
        let wait = SKAction.wait(forDuration: duration)
        let actSeq = SKAction.sequence([create, wait])
        run(SKAction.repeatForever(actSeq))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.frog.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.frog.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 7))
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
