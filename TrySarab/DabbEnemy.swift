//
//  DabbEnemy.swift
//  TrySarab
//
//  Created by Nada Abdullah on 09/09/1446 AH.
//

import Foundation
import SpriteKit

struct PhysicsCategory {
    static let enemy: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let player: UInt32 = 0x1 << 3
}

class DabbEnemy: Enemy {
    private var direction: CGFloat = -1.0 // يتحرك من اليمين إلى اليسار

    override init(node: SKSpriteNode, hp: Int, damage: Int, textures: [SKTexture], speed: CGFloat) {
        super.init(node: node, hp: hp, damage: damage, textures: textures, speed: speed)

        // ✅ ضبط حجم الضب
        node.size = CGSize(width: 809 / 15, height: 1024 / 15)

        // ✅ ضبط الفيزياء
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.friction = 1
        node.physicsBody?.restitution = 0

        // ✅ أهم جزء: منع الضب من التأثير على سراب فيزيائيًا
        node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = PhysicsCategory.ground // ✅ الضب يصطدم بالأرض فقط
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player // ✅ الضب يعرف متى يلمس سراب لكنه لا يدفعه

        node.physicsBody?.affectedByGravity = true // ✅ الضب يتأثر بالجاذبية
        node.physicsBody?.linearDamping = 1.0 // ✅ تقليل الدفع والانزلاق للضب
        node.physicsBody?.mass = 1000 // ✅ جعل الضب ثقيلًا جدًا حتى لا يؤثر على سراب

        // ✅ تشغيل الحركة فورًا
        startMoving()
        startAnimation()
    }

    func startMoving() {
        let moveLeft = SKAction.moveBy(x: -speed * 100, y: 0, duration: 3) // ✅ تسريع الحركة
        let movementSequence = SKAction.repeatForever(moveLeft)
        node.run(movementSequence)
    }

    func startAnimation() {
        let animation = SKAction.animate(with: textures, timePerFrame: 0.2) // ✅ تبديل كل 0.2 ثانية بدون وميض
        let repeatAnimation = SKAction.repeatForever(animation)
        node.run(repeatAnimation)
    }

    override func takeDamage(direction: CGFloat) -> Bool {
        if dmgCD { return false } // التأكد من أن العدو لا يتلقى ضررًا متكررًا سريعًا

        hp -= 10 // تقليل نقاط الصحة

        if hp <= 0 {
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))

            // 🕒 إبلاغ GameScene بأن الضب مات ويجب إعادته
            if let scene = node.scene as? GameScene {
                scene.respawnDabbEnemy(after: 5)
            }
            
            return false // العدو مات
        }

        // تطبيق تأثير الارتداد عند تلقي الضرر
        node.physicsBody?.applyImpulse(CGVector(dx: -20 * direction, dy: 0))

        // منع تلقي ضرر متكرر بسرعة
        dmgCD = true
        let waitAction = SKAction.wait(forDuration: 1)
        let resetDmgCD = SKAction.run { self.dmgCD = false }
        node.run(SKAction.sequence([waitAction, resetDmgCD]))

        return true // العدو لا يزال حيًا
    }
    
    func respawnDabb() {
        guard let scene = node.scene as? GameScene else { return } // التأكد من أن الضب داخل المشهد

        _ = scene.spawnDabbEnemy() // ✅ إنشاء ضب جديد دون حذف القديم
        print("🔄 تم إنشاء ضب جديد!")
    }
    
    
}
