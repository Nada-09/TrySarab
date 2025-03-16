import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var enemyDefeatedCount = 0
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
        // لو عندك إعداد للفيزياء، عيّن الـ contactDelegate
        self.physicsWorld.contactDelegate = self // ✅ ضروري ليتم استدعاء didBegin(_ contact:)
        
        // ابحث عن اللاعب
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
        
        // إعداد الـStateMachine
        if let playerNode = player {
            playerStateMachine = GKStateMachine(states: [
                WalkingState(playerNode: playerNode),
                IdleState(playerNode: playerNode),
                StunnedState(playerNode: playerNode),
                AttackState(playerNode: playerNode)
            ])
            playerStateMachine.enter(IdleState.self)
        }
        
        // Hearts
        heartContainer.position = CGPoint(x: -300, y: 140)
        heartContainer.zPosition = 5
        cameraNode?.addChild(heartContainer)
        fillHearts(count: 3)
        
        // إنشاء ضب أول
        let newDabb = spawnDabbEnemy()
        player?.name = "Sarab" // ✅ اسم اللاعب
        newDabb.node.name = "Dabb" // اسم الضب
        dabbEnemies.append(newDabb)

        print("🎮 Sarab and Dabb names assigned successfully!")
        print("🚀 GameScene تم تحميله بنجاح!")
        
        for node in self.children {
            print("🔍 العقدة في المشهد: \(node.name ?? "بدون اسم")")
        }
        
        print("🐊 تم استدعاء spawnDabbEnemy()")
        
        // مؤقت لتوليد ضبان كل 5 ثوانٍ
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let newDabb = self.spawnDabbEnemy()
            newDabb.node.name = "Dabb"
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

        let newDabb = DabbEnemy(node: dabbNode, hp: 50, damage: 5,
                                textures: [dabbTexture1, dabbTexture2], speed: 4.0)
        addChild(newDabb.node)
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
        heartContainer.removeAllChildren()
        heartsArray.removeAll()
        
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
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if let lastHitTime = enemyHitCooldown[enemy], currentTime - lastHitTime < 1.5 {
            return
        }
        enemyHitCooldown[enemy] = currentTime

        if !heartsArray.isEmpty {
            let lastHeart = heartsArray.removeLast()
            lastHeart.removeFromParent()

            // وميض عند الضرر
            player?.run(flashEffect())

            // لو خلصت القلوب → Game Over
            if heartsArray.isEmpty {
                gameOver()
            }
        }
        
        // منع الضب من ضرب اللاعب ثانيةً قبل 1.5 ثانية
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.enemyHitCooldown.removeValue(forKey: enemy)
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
                self.fillHearts(count: 3)
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
        
        // 1) أنشئ عقدة Sprite بصورة GameOver (يجب أن تكون في Assets)
        let gameOverSprite = SKSpriteNode(imageNamed: "GameOver")
        
        // 2) ضعها في منتصف الشاشة
      //  gameOverSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverSprite.zPosition = 999 // اجعلها في المقدمة
        addChild(gameOverSprite)
        
        // 3) عطّل التفاعل إن أردت منع اللاعب من الحركة
        self.isUserInteractionEnabled = false
    }
}

// MARK: Touches
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // تحقق من لمس الجويستيك
            if let joystickKnob = joystickKnob, let joystick = joystick {
                joystickAction = joystickKnob.frame.contains(touch.location(in: joystick))
            }

            // تحقق من لمس زر الهجوم
            if let attackButton = attackButton, attackButton.contains(location) {
                isAttacking = true
                playerStateMachine.enter(AttackState.self)
                
                // فحص الضب بعد الهجوم (مدى 100)
                checkDabbCollision()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick, let joystickKnob = joystickKnob else { return }
        if !joystickAction { return }
        
        for touch in touches {
            let position = touch.location(in: joystick)
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius,
                                                y: sin(angle) * knobRadius)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // إذا رفع عن زر الهجوم
            if let attackButton = attackButton, attackButton.contains(location) {
                isAttacking = false
                if let spriteNode = player as? SKSpriteNode {
                    spriteNode.texture = SKTexture(imageNamed: "SarabBoy_Standing")
                }
                updatePlayerState()
            }
            
            // إعادة ضبط الجويستيك
            if let joystick = joystick {
                let xJoystickCoordinate = touch.location(in: joystick).x
                let xLimit: CGFloat = 200.0
                if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                    resetKnobPosition()
                }
            }
        }
    }
}

// MARK: Checking Collision with Dabb (Range-based Attack)
extension GameScene {
    func checkDabbCollision() {
        guard let playerNode = player as? SKSpriteNode else { return }
        let playerPosition = playerNode.position
        let attackRange: CGFloat = 100.0

        for dabb in dabbEnemies {
            let dabbPosition = dabb.node.position
            // إذا الضب قريب بما يكفي
            if abs(playerPosition.x - dabbPosition.x) <= attackRange {
                if isAttacking {
                    // ضرب الضب → hp -= 10
                    let attackDirection: CGFloat = playerIsFacingRight ? 1.0 : -1.0
                    let dabbAlive = dabb.takeDamage(direction: attackDirection)
                    
                    if !dabbAlive {
                        // إذا الضب مات
                        dabb.node.run(SKAction.sequence([
                            SKAction.fadeOut(withDuration: 0.5),
                            SKAction.removeFromParent()
                        ]))
                        if let index = dabbEnemies.firstIndex(where: { $0.node == dabb.node }) {
                            dabbEnemies.remove(at: index)
                        }

                        // زِد عدّاد الضبان المهزومة
                        enemyDefeatedCount += 1
                        print("enemyDefeatedCount = \(enemyDefeatedCount)")

                        // إذا وصلنا 3 أو 5 أو 10 → أعرض اللغز
                        if enemyDefeatedCount == 3 {
                            startRandomQuestion(difficulty: "Easy")
                        } else if enemyDefeatedCount == 5 {
                            startRandomQuestion(difficulty: "Medium")
                        } else if enemyDefeatedCount == 10 {
                            startRandomQuestion(difficulty: "Hard")
                        }
                    }
                }
                // إذا لم يكن يهاجم، لا نفعل شيئًا هنا
                // لأن فقد القلب يحصل فقط عند التلامس الفيزيائي في didBegin(_ contact:).
            }
        }
    }
}

// MARK: - تحريك اللاعب في كل فريم
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        // 1) حساب الزمن المنقضي
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
        
        // 3) إذا لم يكن اللاعب في حالة هجوم، حدّث حالته
        if !isAttacking {
            updatePlayerState()
        }
        
        // 4) الحصول على موضع الـJoystick للتحكم في حركة اللاعب
        guard let joystickKnob = joystickKnob else { return }
        let xPosition = Double(joystickKnob.position.x)
        
        // 5) حساب الإزاحة بناءً على قيمة الـJoystick وسرعة اللاعب
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

// MARK: Handle Contact (Lose heart if not attacking)
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node, let bodyB = contact.bodyB.node else { return }

        // إذا صار تلامس بين سراب وضب
        if (bodyA.name == "Sarab" && bodyB.name == "Dabb") ||
           (bodyA.name == "Dabb" && bodyB.name == "Sarab") {
            
            let enemyNode = (bodyA.name == "Dabb") ? bodyA : bodyB

            // ابحث عن هذا الضب في المصفوفة
            if let _ = dabbEnemies.first(where: { $0.node == enemyNode }) {
                
                if isAttacking {
                    // إذا أردت قتل الضب عند اللمس + الهجوم بدلًا من checkDabbCollision،
                    // يمكنك نقل منطق القتل هنا.
                    // حالياً نتركه فارغاً لأن القتل يحصل في checkDabbCollision.
                } else {
                    // إذا سراب لا يهاجم = ينقص قلب
                    loseHeart(from: enemyNode)
                }
            }
        }
    }
}

// MARK: Puzzle
extension GameScene {
    func showPuzzle(question: String,
                    choices: [String],
                    correctAnswer: String,
                    hint: String) {
        
        let puzzleScene = PuzzleScene(size: self.size)
        puzzleScene.scaleMode = .aspectFill
        
        // مرّر بيانات السؤال لمشهد الأحجية
        puzzleScene.questionText = question
        puzzleScene.choices = choices
        puzzleScene.correctAnswer = correctAnswer
        puzzleScene.hintText = hint
        
        self.view?.presentScene(puzzleScene, transition: .fade(withDuration: 1.0))
    }
}

extension GameScene {
    func startRandomQuestion(difficulty: String) {
        // اختر سؤالاً عشوائياً
        var questionsPool: [QuizQuestion] = []
        
        switch difficulty {
        case "Easy":
            questionsPool = easyQuestions
        case "Medium":
            questionsPool = mediumQuestions
        case "Hard":
            questionsPool = hardQuestions
        default:
            questionsPool = easyQuestions
        }
        
        guard let randomQuestion = questionsPool.randomElement() else {
            print("لا توجد أسئلة في المستوى \(difficulty)")
            return
        }
        
        showPuzzle(
            question: randomQuestion.question,
            choices: randomQuestion.choices,
            correctAnswer: randomQuestion.correctAnswer,
            hint: randomQuestion.hint
        )
    }
}

extension GameScene {
    func updatePlayerState() {
        if isAttacking { return }
        
        if let joystickKnob = joystickKnob, floor(abs(joystickKnob.position.x)) != 0 {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
    }
    
    func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        moveBack.timingMode = .linear
        joystickKnob?.run(moveBack)
        joystickAction = false
    }
}
