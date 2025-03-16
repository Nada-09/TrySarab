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
        node.physicsBody?.friction = 0.5
        node.physicsBody?.restitution = 0

        // ✅ أهم جزء: منع الضب من التأثير على سراب فيزيائيًا
        node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = PhysicsCategory.ground // ✅ الآن الضب يصطدم بالأرض
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        node.physicsBody?.affectedByGravity = true // ✅ الضب يتأثر بالجاذبية لكنه لن يطير
        node.physicsBody?.linearDamping = 5.0 // ✅ تقليل الانزلاق والسرعة الزائدة
        node.physicsBody?.mass = 100 // ✅ جعله ثقيلًا حتى لا يتحرك بطريقة غير طبيعية
         
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
        if dmgCD { return false }

        hp -= 10

        if hp <= 0 {
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))

            // ✅ إعادة توليد الضب بعد 3 ثوانٍ
            if let scene = node.scene as? GameScene {
                scene.respawnDabbEnemy(after: 3)
            }

            return false // ✅ الضب مات
        }
        
        
        //        // ✅ تطبيق تأثير الارتداد عند تلقي الضرر
        //        node.physicsBody?.applyImpulse(CGVector(dx: -20 * direction, dy: 0))

        dmgCD = true
        let waitAction = SKAction.wait(forDuration: 1)
        let resetDmgCD = SKAction.run { self.dmgCD = false }
        node.run(SKAction.sequence([waitAction, resetDmgCD]))

        return true
    }


    
    func respawnDabb() {
        guard let scene = node.scene as? GameScene else { return } // التأكد من أن الضب داخل المشهد

        _ = scene.spawnDabbEnemy() // ✅ إنشاء ضب جديد دون حذف القديم
        print("🔄 تم إنشاء ضب جديد!")
    }
    
    
}
