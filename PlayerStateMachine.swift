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
// ممكن أحذفه دام ما عندنا نط
class JumpingState : PlayerState {
    var hasFinishedJumping : Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
  //      if hasFinishedJumping && stateClass is LandingState.Type { return true }
        return true
    }
    
    let textures: Array<SKTexture> = [
        SKTexture(imageNamed: "SarabWalking_Front1"),
        SKTexture(imageNamed: "SarabWalking_Front2")
    ]
    lazy var action = { SKAction.animate(with: textures, timePerFrame: 0.1)} ()
    
    override func didEnter(from previousState: GKState?) {
        
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        hasFinishedJumping = false
        playerNode.run(.applyForce(CGVector(dx:0, dy: 75), duration: 0.1))
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {(timer) in self.hasFinishedJumping = true
            
        }
    }
}

class LandingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is JumpingState.Type:
            return false
        default:
            return true
        }
    }

    override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(IdleState.self)
    }
}

class IdleState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is IdleState.Type:
            return false
        default:
            return true
        }
    }

    let textures = SKTexture(imageNamed: "SarabStanding_Front")
    lazy var action = {
        SKAction.animate(with: [textures], timePerFrame: 0.1)} ()

    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        
//        //شاتي 📍📍📍📍📍📍📍📍
//        if let spriteNode = playerNode as? SKSpriteNode {
//            spriteNode.texture = textures // تعيين الصورة مباشرة بدون   أنيميشن
//        }
    }
}


class WalkingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is WalkingState.Type:
            return false
        default:
            return true
        }
    }

    let textures: Array<SKTexture> = [
        SKTexture(imageNamed: "SarabWalking_Front1"),
        SKTexture(imageNamed: "SarabWalking_Front2"),
        SKTexture(imageNamed: "SarabWalking_Front3"),
        SKTexture(imageNamed: "SarabWalking_Front4")
    ]

    lazy var action = {
        SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1))
    }()
    
    override func didEnter(from previousState: GKState?) {
            if let scene = playerNode.scene {
                scene.backgroundColor = .red // لون أحمر عند دخول حالة المشي
            }

            if previousState is WalkingState { return } // منع إعادة تشغيل الأنيميشن كل مرة
            playerNode.removeAction(forKey: characterAnimationKey)
            playerNode.run(action, withKey: characterAnimationKey)
        }
    }

//    override func didEnter(from previousState: GKState?) {
//        playerNode.removeAction(forKey: characterAnimationKey)
//        playerNode.run(action, withKey: characterAnimationKey)
//    }
//}


class StunnedState: PlayerState {
}
