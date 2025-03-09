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
        SKTexture(imageNamed: "SarabWalking_Front1"),
        SKTexture(imageNamed: "SarabWalking_Front2"),
        SKTexture(imageNamed: "SarabWalking_Front3"),
        SKTexture(imageNamed: "SarabWalking_Front4")
    ]
    lazy var action = { SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1)) }()
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        playerNode.setScale(1.0) // تثبيت الحجم بعد الأنيميشن
    }
}

class StunnedState: PlayerState { }
