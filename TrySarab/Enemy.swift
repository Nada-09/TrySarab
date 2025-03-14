//
//  Enemy.swift
//  TrySarab
//
//  Created by Nada Abdullah on 09/09/1446 AH.
//

import Foundation
import SpriteKit

class Enemy {
    var node: SKSpriteNode
    var hp: Int
    var damage: Int
    var textures: [SKTexture]
    var speed: CGFloat
    var movCD: Bool = false
    var dmgCD: Bool = false

    init(node: SKSpriteNode, hp: Int, damage: Int, textures: [SKTexture], speed: CGFloat) {
        self.node = node
        self.hp = hp
        self.damage = damage
        self.textures = textures
        self.speed = speed
    }

    // حركة العدو (يجب أن يتم تنفيذها في الفئات الفرعية)
    func moveEnemy(direction: CGFloat) {
        fatalError("moveEnemy(direction:) has not been implemented")
    }

    // استقبال الضرر (يجب أن يتم تنفيذها في الفئات الفرعية)
    func takeDamage(direction: CGFloat) -> Bool {
        fatalError("takeDamage(direction:) has not been implemented")
    }

    // تحريك أنيميشن المشي (يجب أن يتم تنفيذه في الفئات الفرعية)
    func animateWalk() {
        fatalError("animateWalk() has not been implemented")
    }
}
