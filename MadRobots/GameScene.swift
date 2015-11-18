//
//  GameScene.swift
//  MadRobots
//
//  Created by Andrei Nechaev on 11/13/15.
//  Copyright (c) 2015 RoboCrowds. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let robot = Robot(name: "player", scale: 0.1)
    let scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
    var collisions = 0

    let date = NSDate()
    var center:CGPoint!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        center = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.texture!.size())
        scoreLabel.position = center
        scoreLabel.fontSize = 25
        scoreLabel.text = "Collisions: \(collisions)"
        self.addChild(scoreLabel)
        
        robot.position = center
        robot.showName = true
        self.addChild(robot)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        let location = touches.first!.locationInNode(self)
        robot.moveTo(location)
        
        let player = [
            "name": "\(date)",
            "x": location.x,
            "y": location.y
        ]
        
        let data = try! NSJSONSerialization.dataWithJSONObject(player, options: .PrettyPrinted)
        ConnectionManager.sharedInstance.send(data)
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        enumerateChildNodesWithName("robot") { node, _ in
            if CGRectIntersectsRect(self.robot.frame, node.frame) {
                self.scoreLabel.text = "Collisions: \(++self.collisions)"
            }
        }
    }
}
