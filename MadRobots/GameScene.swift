//
//  GameScene.swift
//  MadRobots
//
//  Created by Andrei Nechaev on 11/13/15.
//  Copyright (c) 2015 RoboCrowds. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let sprite = SKSpriteNode(imageNamed: "Spaceship")
    let scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
    var collisions = 0
    let websocket = (UIApplication.sharedApplication().delegate as! AppDelegate).websocket
    let date = NSDate()
    var center:CGPoint!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        center = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.texture!.size())
        scoreLabel.position = center
        scoreLabel.fontSize = 25
        scoreLabel.text = "Collisions: \(collisions)"
        
        sprite.position = center
        sprite.xScale = 0.1
        sprite.yScale = 0.1
        sprite.name = "player"
        let nameLabel = SKLabelNode(fontNamed:"Chalkduster")
        nameLabel.text = "\(date)";
        nameLabel.fontSize = 25;
        nameLabel.position = CGPoint(x:CGRectGetMidX(sprite.frame)/2, y:CGRectGetMidY(sprite.frame)/2);
        
        sprite.addChild(nameLabel)
        self.addChild(sprite)
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        let location = touches.first!.locationInNode(self)
        let move = SKAction.moveTo(location, duration: 1.5)
        let rotation = rotateAction(sprite.position, direction: location)
        
        sprite.runAction(SKAction.sequence([rotation, move]))
        
        let player = [
            "name": "\(date)",
            "x": location.x,
            "y": location.y
        ]
        
        let data = try! NSJSONSerialization.dataWithJSONObject(player, options: .PrettyPrinted)
        websocket.writeData(data)
    }
    
    func rotateAction(position: CGPoint, direction: CGPoint) -> SKAction {
        let dx = Float(position.x - direction.x)
        let dy = Float(position.y - direction.y)
        let angle = CGFloat(atan2(dy, dx) + Float(M_PI_2))
        return SKAction.rotateToAngle(angle, duration: 0.2)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        enumerateChildNodesWithName("robot") { node, _ in
            if CGRectIntersectsRect(self.sprite.frame, node.frame) {
                self.scoreLabel.text = "Collisions: \(++self.collisions)"
            }
        }
    }
}
