//
//  Robot.swift
//  MadRobots
//
//  Created by Andrei Nechaev on 11/16/15.
//  Copyright © 2015 RoboCrowds. All rights reserved.
//

import SpriteKit

class Robot: SKSpriteNode {
    
    let nameLabel = SKLabelNode(fontNamed: "Chalkduster")
    var userName: String?
    private let date = NSDate()
    var showName: Bool {
        set {
            if newValue {
                nameLabel.text = userName ?? "\(date)"
                nameLabel.fontSize = 25;
                nameLabel.position = CGPoint(x:CGRectGetMidX(self.frame)/2, y:CGRectGetMidY(self.frame)/2);
                self.addChild(nameLabel)
            }else {
                self.removeChildrenInArray([nameLabel])
            }
        }
        get {
            return self.showName
        }
    }
    
    convenience init(name: String, scale: CGFloat) {
        self.init(imageNamed: "Spaceship")
        self.name = name
        self.xScale = scale
        self.yScale = scale
    }
    
    func moveTo(location: CGPoint) {
        let dx = Float(position.x - location.x)
        let dy = Float(position.y - location.y)
        let angle = CGFloat(atan2(dy, dx) + Float(M_PI_2))
        
        let move = SKAction.moveTo(location, duration: 1.5)
        let rotation = SKAction.rotateToAngle(angle, duration: 0.2)
        self.runAction(SKAction.sequence([rotation, move]))
    }
}
