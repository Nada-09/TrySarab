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
    
    // boolean
    var joystickAction = false
    var isAttacking = false
    
    // Measure
    var knobRadius : CGFloat = 50.0
    
    // Sprite Engine
    var previousTimeInterval : TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 4.0
    
    // Player state
    var playerStateMachine : GKStateMachine!
    
    //didmove
    override func didMove(to view: SKView) {
        
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
                                                    ])
        playerStateMachine.enter(IdleState.self)
    }
}

// MARK: Touches
extension GameScene  {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
            }
            
            let location = touch.location(in: self)
            if !(joystick?.contains(location))! {
                playerStateMachine.enter(IdleState.self)
            }
            
            if let attackButton = attackButton, attackButton.contains(location) {
                if let spriteNode = player as? SKSpriteNode {
                    spriteNode.texture = SKTexture(imageNamed: "SarabAttack_Front")
                }
                isAttacking = true
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
            
            if let attackButton = attackButton, attackButton.contains(location) {
                isAttacking = false

                // إعادة تعيين الصورة بناءً على الحالة
                if let spriteNode = player as? SKSpriteNode {
                    spriteNode.texture = SKTexture(imageNamed: "SarabStanding_Front") // الصورة الأصلية
                }

                updatePlayerState()
            }
            
            
            let xJoystickCoordinate = touch.location(in: joystick!).x
            let xLimit: CGFloat = 200.0
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
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
        let positivePosition = xPosition < 0 ? -xPosition : xPosition
        
        // إذا الهجوم مو مفعّل، حدّث الحالة حسب الحركة
        if !isAttacking {
            updatePlayerState()
        }
        
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)
        let faceAction : SKAction!
        let movingRight = xPosition > 0
        let movingLeft = xPosition < 0
        if movingLeft && playerIsFacingRight {
            playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: -1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        }
        else if movingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else {
            faceAction = move
        }
        player?.run(faceAction)
    }
}


