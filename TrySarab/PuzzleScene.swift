import SpriteKit

class PuzzleScene: SKScene {
    // البيانات التي تأتي من GameScene
    var questionText: String = ""
    var choices: [String] = []
    var correctAnswer: String = ""
    var hintText: String = ""
    
    // ⏰ لتسجيل وقت بدء اللغز
    private var puzzleStartTime: CFAbsoluteTime = 0
    
    // مراجع للعناصر كي نتحكم بها
    private var questionLabel: SKLabelNode?
    private var choiceLabels: [SKLabelNode] = []
    private var closePuzzleLabel: SKLabelNode? // زر إغلاق اللغز
    
    // مراجع لعناصر التلميح
    private var hintLabelNode: SKLabelNode?
    private var backButton: SKLabelNode?
    
    override func didMove(to view: SKView) {
        // نسجّل وقت البدء، لكن لن نُظهره إلا عند الإجابة الصحيحة
        puzzleStartTime = CFAbsoluteTimeGetCurrent()
        
        backgroundColor = .magenta
        
        // خلفية الصورة (إذا لديك صورة باسم "Puzzle" في الـAssets)
        let background = SKSpriteNode(imageNamed: "Puzzle")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 0
        background.size = self.size
        addChild(background)
        
        // 1) نص السؤال
        let qLabel = SKLabelNode(text: questionText)
        qLabel.fontName = "Chalkduster"
        qLabel.fontSize = 24
        qLabel.fontColor = .black
        qLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 80)
        qLabel.zPosition = 1
        addChild(qLabel)
        self.questionLabel = qLabel
        
        // 2) عرض الاختيارات
        for (index, choice) in choices.enumerated() {
            let choiceLabel = SKLabelNode(text: choice)
            choiceLabel.fontName = "Chalkduster"
            choiceLabel.fontSize = 20
            choiceLabel.fontColor = .blue
            // ترتيب بسيط: كل خيار ينزل 30 نقطة عن سابقه
            choiceLabel.position = CGPoint(
                x: size.width/2,
                y: size.height/2 - CGFloat(index * 30)
            )
            choiceLabel.name = "choice_\(index)"
            choiceLabel.zPosition = 1
            addChild(choiceLabel)
            
            choiceLabels.append(choiceLabel)
        }
        
        // 3) زر إغلاق اللغز (لا نريد إظهاره الآن)
        let closeLabel = SKLabelNode(text: "إغلاق اللغز")
        closeLabel.fontName = "Chalkduster"
        closeLabel.fontSize = 20
        closeLabel.fontColor = .red
        closeLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 150)
        closeLabel.zPosition = 1
        closeLabel.name = "closePuzzleButton"
        closeLabel.isHidden = true // اجعله مخفيًا حتى يجيب إجابة صحيحة
        addChild(closeLabel)
        self.closePuzzleLabel = closeLabel
        
        // 4) زر التلميح
        let hintButton = SKLabelNode(text: "تلميح")
        hintButton.fontName = "Chalkduster"
        hintButton.fontSize = 20
        hintButton.fontColor = .brown
        hintButton.position = CGPoint(x: size.width/2 + 100, y: size.height/2 - 150)
        hintButton.zPosition = 1
        hintButton.name = "hintButton"
        addChild(hintButton)
    }
    
    // التقاط اللمس
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = self.nodes(at: location)
        
        for node in touchedNodes {
            // 1) زر الإغلاق (يظهر فقط بعد الإجابة الصحيحة)
            if node.name == "closePuzzleButton" {
                // بدلًا من:
                // let gameScene = GameScene(size: self.size)
                // gameScene.scaleMode = .aspectFill
                // self.view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
                
                // استخدم:
                if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene, transition: .fade(withDuration: 1.0))
                } else {
                    print("⚠️ لم أجد ملف GameScene.sks أو لم أستطع تحويله إلى GameScene")
                }
            }
            // 2) زر التلميح
            else if node.name == "hintButton" {
                showHint()
            }
            // 3) زر العودة من شاشة التلميح
            else if node.name == "backButton" {
                hideHint()
            }
            // 4) اختيار إجابة
            else if let nodeName = node.name, nodeName.hasPrefix("choice_") {
                handleChoiceSelection(nodeName)
            }
        }
    }
    
    // MARK: - تلميح
    func showHint() {
        // 1) أخفِ السؤال والخيارات
        questionLabel?.isHidden = true
        for choiceLabel in choiceLabels {
            choiceLabel.isHidden = true
        }
        
        // 2) أنشئ تسمية التلميح
        let hLabel = SKLabelNode(text: hintText)
        hLabel.fontName = "Chalkduster"
        hLabel.fontSize = 24
        hLabel.fontColor = .darkGray
        hLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        hLabel.zPosition = 2
        hLabel.name = "hintLabel"
        addChild(hLabel)
        self.hintLabelNode = hLabel
        
        // 3) زر "عودة"
        let back = SKLabelNode(text: "عودة")
        back.fontName = "Chalkduster"
        back.fontSize = 20
        back.fontColor = .blue
        back.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        back.zPosition = 2
        back.name = "backButton"
        addChild(back)
        self.backButton = back
    }
    
    func hideHint() {
        // أزل التلميح وزر العودة
        hintLabelNode?.removeFromParent()
        backButton?.removeFromParent()
        hintLabelNode = nil
        backButton = nil
        
        // أظهر السؤال والخيارات
        questionLabel?.isHidden = false
        for choiceLabel in choiceLabels {
            choiceLabel.isHidden = false
        }
    }
    
    // MARK: - اختيار الإجابة
    func handleChoiceSelection(_ choiceName: String) {
        guard let indexString = choiceName.split(separator: "_").last,
              let index = Int(indexString) else { return }
        
        let chosenAnswer = choices[index]
        
        if chosenAnswer == correctAnswer {
            // ✅ إذا كانت الإجابة صحيحة، نحسب الوقت
            let timeSpent = CFAbsoluteTimeGetCurrent() - puzzleStartTime
            let timeString = String(format: "%.2f", timeSpent)
            
            print("✅ إجابة صحيحة! الوقت المستغرق: \(timeString) ثانية")
            
            let correctLabel = SKLabelNode(text: "إجابة صحيحة! ⏳ \(timeString) ثانية")
            correctLabel.fontSize = 24
            correctLabel.fontColor = .green
            correctLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
            correctLabel.zPosition = 3
            addChild(correctLabel)
            
            // إظهار زر "إغلاق اللغز" بعد الإجابة الصحيحة
            closePuzzleLabel?.isHidden = false
            
        } else {
            // ❌ إجابة خاطئة (لا نحسب الوقت)
            print("❌ إجابة خاطئة! لن نحسب الوقت.")
            
            let wrongLabel = SKLabelNode(text: "إجابة خاطئة!")
            wrongLabel.fontSize = 24
            wrongLabel.fontColor = .red
            wrongLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
            wrongLabel.zPosition = 3
            addChild(wrongLabel)
        }
    }
}
