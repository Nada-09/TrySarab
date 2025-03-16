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
    var dabbEnemies: [DabbEnemy] = []
    var firstDabb: SKNode? // ✅ المتغير المسؤول عن تحديد الضب الأول دائمًا

    
    // boolean
    var joystickAction = false
    var isAttacking = false
    var isHit = false // ✅ متغير لمنع الضرر المتكرر
    
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
        self.physicsWorld.contactDelegate = self // ✅ ضروري ليتم استدعاء `didBegin(_ contact:)`
        
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
        
        let newDabb = spawnDabbEnemy() // إنشاء ضب جديد

        player?.name = "Sarab" // ✅ تحديد اسم سراب
        newDabb.node.name = "Dabb"    // تسمية الضب
        dabbEnemies.append(newDabb)   // إضافته للمصفوفة

        print("🎮 Sarab and Dabb names assigned successfully!")
        
        print("🚀 GameScene تم تحميله بنجاح!")
        for node in self.children {
            print("🔍 العقدة في المشهد: \(node.name ?? "بدون اسم")")
        }
        
        // ✅ طباعة رسالة للتأكد أن `spawnDabbEnemy()` تعمل
        print("🐊 تم استدعاء spawnDabbEnemy()")
        
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let newDabb = self.spawnDabbEnemy()
            newDabb.node.name = "Dabb" // <-- مهم جدًا
            self.dabbEnemies.append(newDabb)
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
        
    //    self.dabb = newDabb // ✅ تخزين العدو في المتغير `dabb`
        
        return newDabb
    }
    
    func respawnDabbEnemy(after delay: TimeInterval) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let newDabb = self.spawnDabbEnemy()
            newDabb.node.name = "Dabb"
            self.dabbEnemies.append(newDabb)
        }
    }
    
    func fillHearts(count: Int) {
        heartContainer.removeAllChildren() // ✅ حذف القلوب القديمة قبل الإضافة الجديدة
        heartsArray.removeAll() // ✅ مسح المصفوفة لضمان عدم تكرار القلوب
        
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.size = CGSize(width: 40, height: 40)
            let xPosition = heart.size.width * CGFloat(index - 1)
            heart.position = CGPoint(x: xPosition, y: 0)
            heart.zPosition = 100
            heartsArray.append(heart)
            heartContainer.addChild(heart)
        }
    }
    
    var enemyHitCooldown = [SKNode: TimeInterval]() // ✅ تتبع آخر مرة تسبب كل ضب في الضرر

    func loseHeart(from enemy: SKNode) {
        let currentTime = CFAbsoluteTimeGetCurrent() // ✅ الحصول على الوقت الحالي

        // ✅ التأكد من أن الضب لا يسبب ضررًا مستمرًا كل ثانية
        if let lastHitTime = enemyHitCooldown[enemy], currentTime - lastHitTime < 1.5 {
            return
        }

        // ✅ تسجيل وقت الضرر الجديد لهذا الضب
        enemyHitCooldown[enemy] = currentTime

        if !heartsArray.isEmpty {
            let lastHeart = heartsArray.removeLast()
            lastHeart.removeFromParent()

            // ✅ إضافة وميض عند تلقي الضرر
            player?.run(flashEffect())

            // ✅ إذا انتهت القلوب، إنهاء اللعبة
            if heartsArray.isEmpty {
                gameOver()
            }
        }

        // ✅ تعطيل الضرر من هذا الضب مؤقتًا
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.enemyHitCooldown.removeValue(forKey: enemy) // ✅ إزالة الضب من قائمة الحماية بعد 1.5 ثانية
        }
    }
    
    func dying() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let gameOverScreen = SKAction.run {
            let gameOverLabel = SKLabelNode(text: "Game Over")
            gameOverLabel.fontSize = 50
            gameOverLabel.fontColor = .red
            gameOverLabel.position = CGPoint(x: 0, y: 0)
            gameOverLabel.zPosition = 10
            self.addChild(gameOverLabel)

            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                gameOverLabel.removeFromParent()
                self.fillHearts(count: 3) // ✅ إعادة القلوب بعد الموت
                self.player?.position = CGPoint(x: 0, y: 0)
                self.player?.alpha = 1.0
            }
        }
        
        player?.run(SKAction.sequence([fadeOut, gameOverScreen]))
    }
    
    
    func flashEffect() -> SKAction {
        return SKAction.repeat(.sequence([
            .fadeAlpha(to: 0.5, duration: 0.1),
            .wait(forDuration: 0.1),
            .fadeAlpha(to: 1.0, duration: 0.1),
            .wait(forDuration: 0.1)
        ]), count: 5)
    }
    
    
    
    func gameOver() {
        print("GAME OVER")
        let gameOverScene = GameScene(size: self.size)
        gameOverScene.scaleMode = self.scaleMode
        self.view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1))
    }
}



// MARK: Touches
extension GameScene {
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
                playerStateMachine.enter(AttackState.self)
                checkDabbCollision() // ✅ إضافة دالة فحص الضب بعد الهجوم
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
            
            // ✅ عند رفع الإصبع عن زر الهجوم، إيقاف حالة الهجوم وإرجاع `texture` الأصلي
            if let attackButton = attackButton, attackButton.contains(location) {
                isAttacking = false
                if let spriteNode = player as? SKSpriteNode {
                    spriteNode.texture = SKTexture(imageNamed: "SarabBoy_Standing")
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

// MARK: Checking Collision with Dabb
extension GameScene {
    func checkDabbCollision() {
        guard let playerNode = player as? SKSpriteNode else { return }
        let playerPosition = playerNode.position
        let attackRange: CGFloat = 100.0

        for dabb in dabbEnemies {
            let dabbPosition = dabb.node.position
            if abs(playerPosition.x - dabbPosition.x) <= attackRange {
                // إذا سراب تهاجم من مسافة
                if isAttacking {
                    // سراب تضرب الضب → الضب يختفي بدون فقد قلب
                    let attackDirection: CGFloat = playerIsFacingRight ? 1.0 : -1.0
                    let dabbAlive = dabb.takeDamage(direction: attackDirection)
                    
                    if !dabbAlive {
                        dabb.node.run(SKAction.sequence([
                            SKAction.fadeOut(withDuration: 0.5),
                            SKAction.removeFromParent()
                        ]))
                        // أزل الضب من المصفوفة
                        if let index = dabbEnemies.firstIndex(where: { $0.node == dabb.node }) {
                            dabbEnemies.remove(at: index)
                        }
                    }
                }
                // إذا لم تكن تهاجم (!isAttacking) فلا نفعل شيئًا هنا،
                // لأن فقدان القلب يحصل فقط عند التلامس الفعلي في didBegin(_ contact:).
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
        // 1) حساب الزمن المنقضي (Delta Time)
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        // 2) تحريك الكاميرا والـJoystick وزر الهجوم مع حركة اللاعب
        if let playerNode = player {
            cameraNode?.position.x = playerNode.position.x
        }
        joystick?.position.y = (cameraNode?.position.y ?? 0) - 100
        joystick?.position.x = (cameraNode?.position.x ?? 0) - 300
        
        if let cameraNode = cameraNode {
            attackButton?.position = CGPoint(
                x: cameraNode.position.x + (self.frame.maxX - 120),
                y: cameraNode.position.y + (self.frame.minY + 100)
            )
        }
        
        // 3) إذا لم يكن اللاعب في حالة هجوم، حدّث حالته (Idle/Walking)
        if !isAttacking {
            updatePlayerState()
        }
        
        // 4) الحصول على موضع الـJoystick للتحكم في حركة اللاعب
        guard let joystickKnob = joystickKnob else { return }
        let xPosition = Double(joystickKnob.position.x)
        
        // 5) حساب الإزاحة (Displacement) بناءً على قيمة الـJoystick وسرعة اللاعب
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let moveAction = SKAction.move(by: displacement, duration: 0)
        
        // 6) تحديد ما إذا كنا بحاجة لقلب اتجاه اللاعب (يمين/يسار)
        var finalAction: SKAction
        if xPosition < 0 && playerIsFacingRight {
            playerIsFacingRight = false
            let flipLeft = SKAction.scaleX(to: -1, duration: 0.0)
            finalAction = SKAction.sequence([moveAction, flipLeft])
        } else if xPosition > 0 && !playerIsFacingRight {
            playerIsFacingRight = true
            let flipRight = SKAction.scaleX(to: 1, duration: 0.0)
            finalAction = SKAction.sequence([moveAction, flipRight])
        } else {
            finalAction = moveAction
        }
        
        // 7) تنفيذ حركة اللاعب فقط إذا لم يكن في حالة هجوم
        if !isAttacking {
            player?.run(finalAction)
        }
    }
}

// MARK: Handle Contact
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node, let bodyB = contact.bodyB.node else { return }

        // إذا صار تلامس بين سراب وضب
        if (bodyA.name == "Sarab" && bodyB.name == "Dabb") || (bodyA.name == "Dabb" && bodyB.name == "Sarab") {
            let enemyNode = (bodyA.name == "Dabb") ? bodyA : bodyB

            // ابحث عن هذا الضب في المصفوفة
            if let _ = dabbEnemies.first(where: { $0.node == enemyNode }) {
                
                if isAttacking {
                    // 1) إذا سراب تهاجم = الضب يموت بدون فقد قلب
                    enemyNode.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                    if let index = dabbEnemies.firstIndex(where: { $0.node == enemyNode }) {
                        dabbEnemies.remove(at: index)
                    }
                } else {
                    // 2) إذا سراب لا تهاجم = ينقص قلب + الضب يكمل طريقه
                    loseHeart(from: enemyNode)
                    // لا تحذف الضب من المشهد أو من المصفوفة هنا
                }
            }
        }
    }
}
