//
//  GameScene.swift
//  TrySarab
//
//  Created by Nada Abdullah on 05/09/1446 AH.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //Nodes
    var player : SKNode?
    var joystick : SKNode?
    var joystickKnob : SKNode?
    var cameraNode : SKCameraNode?
    var attackButton: SKSpriteNode?
    var dabb: DabbEnemy?
    
    // boolean
    var joystickAction = false
    var isAttacking = false
    
    // Measure
    var knobRadius : CGFloat = 50.0
    
    // Hearts
    var heartsArray = [SKSpriteNode]()
    let heartContainer = SKSpriteNode()
    
    // Sprite Engine
    var previousTimeInterval : TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 4.0
    
    // Player state
    var playerStateMachine : GKStateMachine!
    
    //didmove
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self // ✅ ضروري ليتم استدعاء didBegin(_ contact:)
        
        
        player = childNode(withName: "sarabBoy")
        joystick = childNode(withName: "joyStick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
        
        
        if let button = childNode(withName: "attack") as? SKSpriteNode {
            attackButton = button
            attackButton?.position = CGPoint(x: self.frame.maxX - 120, y: self.frame.minY + 100)
            attackButton?.zPosition = 100
            attackButton?.isUserInteractionEnabled = false // عشان ما يتحرك بالغلط
        }
        
        playerStateMachine = GKStateMachine(states: [
            WalkingState(playerNode: player!),
            IdleState(playerNode: player!),
            StunnedState(playerNode: player!),
            AttackState(playerNode: player!)
        ])
        playerStateMachine.enter(IdleState.self)
        
        
        // Hearts
        heartContainer.position = CGPoint(x: -300, y: 140)
        heartContainer.zPosition = 5
        cameraNode?.addChild(heartContainer)
        fillHearts(count: 3)
        
        
        dabb = spawnDabbEnemy() // ✅ تخزين الكائن المرجع حتى يمكن استخدامه لاحقًا
        print("🚀 GameScene تم تحميله بنجاح!")
        for node in self.children {
            print("🔍 العقدة في المشهد: \(node.name ?? "بدون اسم")")
        }
        
        // ✅ طباعة رسالة للتأكد أن spawnDabbEnemy() تعمل
        print("🐊 تم استدعاء spawnDabbEnemy()")
        
        
        // ✅ جعل الضب يظهر تلقائيًا كل 5 ثوانٍ
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            _ = self?.spawnDabbEnemy() // ✅ إنشاء ضب جديد كل 5 ثوانٍ بدون تحذيرات
            print("🔄 ضب جديد ظهر!")
        }
    }
    
    
    func spawnDabbEnemy() -> DabbEnemy {
        let dabbTexture1 = SKTexture(imageNamed: "Dabb_1")
        let dabbTexture2 = SKTexture(imageNamed: "Dabb_2")

        let dabbNode = SKSpriteNode(texture: dabbTexture1)
        let startX = self.frame.maxX + 100
        let startY: CGFloat = 100
        dabbNode.position = CGPoint(x: startX, y: startY)

        let newDabb = DabbEnemy(node: dabbNode, hp: 50, damage: 5, textures: [dabbTexture1, dabbTexture2], speed: 4.0)

        addChild(newDabb.node)
        
        self.dabb = newDabb // ✅ تخزين العدو في المتغير dabb
        
        return newDabb
    }
    
    
    func respawnDabbEnemy(after delay: TimeInterval) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.dabb = self.spawnDabbEnemy() // ✅ إعادة توليد الضب بعد انتهاء المؤقت
        }
    }
    
    func fillHearts(count: Int) {
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.size = CGSize(width: 40, height: 40) // ✅ تعديل حجم القلوب
            let xPosition = heart.size.width * CGFloat(index - 1)
            heart.position = CGPoint(x: xPosition, y: 0)
            heart.zPosition = 100
            heartsArray.append(heart)
            heartContainer.addChild(heart)
        }
    }
    
    
    func gameOver() {
        print("GAME OVER")
        let gameOverScene = GameScene(size: self.size)
        gameOverScene.scaleMode = self.scaleMode
        self.view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1))
    }
    
}

// MARK: Touches
extension GameScene  {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // ✅ تحقق مما إذا كان اللاعب لمس الجويستيك
            if let joystickKnob = joystickKnob, let joystick = joystick {
                joystickAction = joystickKnob.frame.contains(touch.location(in: joystick))
            }

            // ✅ تحقق مما إذا كان اللاعب لمس زر الهجوم
            if let attackButton = attackButton, attackButton.contains(location) {
                isAttacking = true
                playerStateMachine.enter(AttackState.self) // ✅ إدخال سراب في حالة الهجوم
                checkDabbCollision()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
        if !joystickAction { return }
        
        for touch in touches {
            let position = touch.location(in: joystick)
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // ✅ عند رفع الإصبع عن زر الهجوم، إيقاف حالة الهجوم وإرجاع texture الأصلي
            if let attackButton = attackButton, attackButton.contains(location) {
                isAttacking = false
                if let spriteNode = player as? SKSpriteNode {
                    spriteNode.texture = SKTexture(imageNamed: "SarabStanding_Front")
                }
                updatePlayerState()
            }
            
            // ✅ إعادة ضبط الجويستيك عند رفع الإصبع
            let xJoystickCoordinate = touch.location(in: joystick!).x
            let xLimit: CGFloat = 200.0
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
            }
        }
    }
}

//// MARK: Touches
//extension GameScene  {
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            if let joystickKnob = joystickKnob {
//                let location = touch.location(in: joystick!)
//                joystickAction = joystickKnob.frame.contains(location)
//            }
//
//            let location = touch.location(in: self)
//            if !(joystick?.contains(location))! {
//                playerStateMachine.enter(IdleState.self)
//            }
//
//            if let attackButton = attackButton, attackButton.contains(location) {
//                isAttacking = true
//                playerStateMachine.enter(AttackState.self) // ✅ بدلًا من تغيير الصورة يدويًا
//                checkDabbCollision()
//            }
//
//        }
//
//    }
//
//
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let joystick = joystick else { return }
//        guard let joystickKnob = joystickKnob else { return }
//        if !joystickAction { return }
//        for touch in touches {
//            let position = touch.location(in: joystick)
//            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
//            let angle = atan2(position.y, position.x)
//            if knobRadius > length {
//                joystickKnob.position = position
//            } else {
//                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
//            }
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: self)
//
//            if let attackButton = attackButton, attackButton.contains(location) {
//                isAttacking = false
//
//                // إعادة تعيين الصورة بناءً على الحالة
//                if let spriteNode = player as? SKSpriteNode {
//                    spriteNode.texture = SKTexture(imageNamed: "SarabStanding_Front") // الصورة الأصلية
//                }
//
//                updatePlayerState()
//            }
//
//
//            let xJoystickCoordinate = touch.location(in: joystick!).x
//            let xLimit: CGFloat = 200.0
//            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
//                resetKnobPosition()
//            }
//        }
//    }
//}

// MARK: Checking Collision with Dabb
extension GameScene {
    func checkDabbCollision() {
        
        guard let dabb = dabb else { return }
        guard let playerNode = player as? SKSpriteNode else { return }
        
        let playerPosition = playerNode.position
        let dabbPosition = dabb.node.position
        let attackRange: CGFloat = 100.0  // 🔥 **فحص إذا كان اللاعب قريبًا من الضب**
        
        if abs(playerPosition.x - dabbPosition.x) <= attackRange {
            let attackDirection: CGFloat = playerIsFacingRight ? 1.0 : -1.0
            let dabbAlive = dabb.takeDamage(direction: attackDirection)

            if !dabbAlive {
                self.dabb = nil // ✅ تعيين dabb إلى nil بعد موته

            }
        }
    }
}

// MARK: Action
extension GameScene {
    func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        moveBack.timingMode = .linear
        joystickKnob?.run(moveBack)
        joystickAction = false
    }
    
    func updatePlayerState() {
        if isAttacking { return }

        if let joystickKnob = joystickKnob, floor(abs(joystickKnob.position.x)) != 0 {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
    }
}

// MARK: Game Loop
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        cameraNode?.position.x = player!.position.x
        joystick?.position.y = (cameraNode?.position.y)! - 100
        joystick?.position.x = (cameraNode?.position.x)! - 300
        attackButton?.position = CGPoint(x: cameraNode!.position.x + (self.frame.maxX - 120), y: cameraNode!.position.y + (self.frame.minY + 100))
        
        guard let joystickKnob = joystickKnob else { return }
        let xPosition = Double(joystickKnob.position.x)
//        let positivePosition = xPosition < 0 ? -xPosition : xPosition
        
        // إذا الهجوم مو مفعّل، حدّث الحالة حسب الحركة
        if !isAttacking {
            updatePlayerState()
        }
        
        // ✅ تحريك اللاعب بناءً على موقع الجويستيك
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)

        var faceAction: SKAction!
        

        // ✅ التحقق من الاتجاه لتغيير الوجهة
        if xPosition < 0 && playerIsFacingRight {
            playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: -1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else if xPosition > 0 && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else {
            faceAction = move
        }

        // ✅ تحريك اللاعب فقط إذا لم يكن في حالة الهجوم
        if !isAttacking {
            player?.run(faceAction)
        }
    }
//        let movingRight = xPosition > 0
//        let movingLeft = xPosition < 0
//        if movingLeft && playerIsFacingRight {
//            playerIsFacingRight = false
//            let faceMovement = SKAction.scaleX(to: -1, duration: 0.0)
//            faceAction = SKAction.sequence([move, faceMovement])
//        }
//        else if movingRight && !playerIsFacingRight {
//            playerIsFacingRight = true
//            let faceMovement = SKAction.scaleX(to: 1, duration: 0.0)
//            faceAction = SKAction.sequence([move, faceMovement])
//        } else {
//            faceAction = move
//        }
//        player?.run(faceAction)
    }
    
    // MARK: Handle Contact
    extension GameScene: SKPhysicsContactDelegate {
        func didBegin(_ contact: SKPhysicsContact) {
            let bodyA = contact.bodyA
            let bodyB = contact.bodyB

            if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
               (bodyB.categoryBitMask == PhysicsCategory.player && bodyA.categoryBitMask == PhysicsCategory.enemy) {
                
                if isAttacking {
                    if let dabb = dabb {
                        dabb.node.run(SKAction.sequence([
                            SKAction.fadeOut(withDuration: 0.5),
                            SKAction.removeFromParent()
                        ]))
                        self.dabb = nil
                    }
                } else {
                    if heartsArray.count > 0 {
                        let lostHeart = heartsArray.removeLast()
                        lostHeart.removeFromParent()
                    }

                    if heartsArray.isEmpty {
                        gameOver()
                    }
                }
            }
        }
    }
