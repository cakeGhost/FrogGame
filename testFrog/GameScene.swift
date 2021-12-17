//
//  GameScene.swift
//  testFrog
//
//  Created by suding on 2021/12/09.
//
import SpriteKit
import GameplayKit

// MARK: 게임 상태 정의
enum GameState {
    case ready
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
 
  
    // MARK: 개구리 노드
    var frog = SKSpriteNode()
    
    // MARK: 점수 & 점수 node
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    var scoreLabel = SKLabelNode()
    
    
    // MARK: 게임 스테이트를 인식할 gameState변수를 만들어줌
    var gameState = GameState.ready // 초기상태는 ready니까 ready상태로 초기화함
    var moving: SKNode!
    var restartBTN = SKSpriteNode()
    
    
    // MARK: Sprite
    
    override func didMove(to view: SKView) {
        moving = SKNode()
        createFrog()
        createEnvironment()
        createScore()
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -10) // -9.8은 개구리가 아주 지멋대로임 아주 그냥
        
    }
    
    
    
    // MARK: 점수 표현
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = .yellow
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 150)
        scoreLabel.zPosition = 14
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "\(score)"
        addChild(scoreLabel)
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
        frog.physicsBody?.isDynamic = false // 원래 true
        self.addChild(frog)
        print(frog.position)
        
    }
    
    // MARK: 배경화면 만들기
    func createEnvironment() {
        
        let environmentAtlas = SKTextureAtlas(named: "Environment")
        let landTexture = environmentAtlas.textureNamed("ground")
        let landRepeatNum = Int(ceil(self.size.width / landTexture.size().width))
        
        
        for i in 0...landRepeatNum {
            let land = SKSpriteNode(texture: landTexture)
            land.anchorPoint = CGPoint.zero // anchorPoint 어디 기준으로 이미지를 붙힐지
            land.position = CGPoint(x: CGFloat(i) * land.size.width, y: 0)
        //   land.position = CGPoint(x: CGFloat(i), y: -(self.frame.size.height / 2) * 0.25)
            land.zPosition = 3
            
            // 아 ........ 여기 수정 수정수정
            land.physicsBody = SKPhysicsBody(rectangleOf: land.size,
                                             center: CGPoint(x: land.size.width / 2, y: land.size.height / 6))
            
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
        
        let obstacleCollision = SKSpriteNode(color: UIColor.black, size: CGSize(width: 1, height: self.size.height))
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
        obstacleDown.position = CGPoint(x: xPos,
                                        y: obstacleDown.position.y + wallDistance + obstacleUp.size.height)
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
            self.setupObstacle(wallDistance: 480)
            
        }
        let wait = SKAction.wait(forDuration: duration)
        let actSeq = SKAction.sequence([create, wait])
        run(SKAction.repeatForever(actSeq))
    }
    
    
    // MARK: 터치 이벤트
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //  switch문 넣었으므로 주석 처리
        //  self.frog.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        //  self.frog.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        
        switch gameState {
        case .ready:
            gameState = .playing
            self.frog.physicsBody?.isDynamic = true
            self.frog.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
            createForever(duration: 3)
            
        case .playing:
            self.frog.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.frog.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40)) // 원래 50으로했음 ~ 점프하는강도임
        case .dead:
            let scene = GameScene(size: self.size)
            let transition = SKTransition.doorsOpenVertical(withDuration: 1)
            self.view?.presentScene(scene, transition: transition)
            
        }
  
    }
    
    func createBTN() {
       restartBTN = SKSpriteNode(imageNamed: "restart")
        restartBTN.position = CGPoint(x: self.size.width / 2, y: self.size.height - 250)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
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
            print("land에 부딫힘 죽어야함")
            gameOver()
            createBTN()
        case PhysicsCategory.wallUp:
            print("위에 장애물")
            gameOver()
            createBTN()
        case PhysicsCategory.wallDown:
            print("아래장애물")
            gameOver()
            createBTN()
        case PhysicsCategory.score:
            print("점수")
            score += 1
            print(score)
        default:
            break
        }
    }
    
    
    // MARK: 게임 오버
    func gameOver() {
        self.gameState = .dead
        //demageEffect()
        createBTN()
        // Scene 멈추기
        self.isPaused = true
        
    }
    
    
    func demageEffect() {
        let flashNode = SKSpriteNode(color: UIColor(ciColor: .gray), size: self.size)
        let actionSequence = SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.removeFromParent()])
        flashNode.name = "flashNode"
        flashNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        flashNode.zPosition = 17
        addChild(flashNode)
        flashNode.run(actionSequence)
    }
}
