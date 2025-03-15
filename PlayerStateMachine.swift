//
//  PlayerStateMachine.swift
//  TrySarab
//
//  Created by Nada Abdullah on 07/09/1446 AH.
//

import Foundation
import GameplayKit

fileprivate let characterAnimationKey = "Sarab Animation"

class PlayerState: GKState {
    unowned var playerNode: SKNode
    var isAttacking = false // ✅ جعل `isAttacking` متاحًا داخل جميع الحالات

    
    init(playerNode : SKNode) {
        self.playerNode = playerNode
        super.init()
    }
}

class IdleState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return !(stateClass is IdleState.Type)
    }
    let textures = SKTexture(imageNamed: "SarabStanding_Front")
    lazy var action = { SKAction.animate(with: [textures], timePerFrame: 0.1)} ()
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        playerNode.setScale(1.0) // تثبيت الحجم بعد الأنيميشن
    }
}

class WalkingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return !(stateClass is WalkingState.Type)
    }
    let textures: Array<SKTexture> = [
        SKTexture(imageNamed: "Boy_Walk1"),
        SKTexture(imageNamed: "Boy_Walk2"),
        SKTexture(imageNamed: "Boy_Walk3"),
        SKTexture(imageNamed: "Boy_Walk4")
    ]
    lazy var action = { SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1)) }()
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        playerNode.setScale(1.0) // تثبيت الحجم بعد الأنيميشن
    }
}

class AttackState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return !(stateClass is AttackState.Type) // ✅ لا يمكن البقاء في حالة الهجوم للأبد
    }

    let textures: Array<SKTexture> = [
        SKTexture(imageNamed: "Boy_Hit")
    ]
    
    lazy var action = { SKAction.animate(with: textures, timePerFrame: 0.1) }()

    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)

        isAttacking = true // ✅ تفعيل الهجوم مؤقتًا

        let waitAction = SKAction.wait(forDuration: 0.5) // مدة الهجوم
        let returnToIdle = SKAction.run { [weak self] in
            self?.isAttacking = false // ✅ إيقاف الهجوم بعد 0.5 ثانية
            self?.stateMachine?.enter(IdleState.self)
        }
        
        playerNode.run(SKAction.sequence([waitAction, returnToIdle]))
    }
}

class StunnedState: PlayerState { }
