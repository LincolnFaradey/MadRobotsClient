//
//  GameViewController.swift
//  MadRobots
//
//  Created by Andrei Nechaev on 11/13/15.
//  Copyright (c) 2015 RoboCrowds. All rights reserved.
//

import UIKit
import SpriteKit
import Starscream

class GameViewController: UIViewController, ConnectionManagerDelegate {
    let scene = GameScene(fileNamed:"GameScene")
    var robots = [String: Robot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConnectionManager.sharedInstance.delegate = self
        
        if let sc = scene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            sc.scaleMode = .AspectFill
            
            skView.presentScene(sc)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ConnectionManager.sharedInstance.establishConnection()
    }

    
    //MARK: ConnectionManagerDelegate
    func connected() {
        print("Connected")
        let player = [
            "name": "\(scene!.date)",
            "x": scene!.robot.position.x,
            "y": scene!.robot.position.y
        ]
        robots["\(scene!.date)"] = scene!.robot
        
        let data = try! NSJSONSerialization.dataWithJSONObject(player, options: .PrettyPrinted)
        ConnectionManager.sharedInstance.send(data)
    }
    
    func disconnected(error: NSError?) {
        print("Disconnected with error: \(error?.userInfo)")
    }

    func managerDidReceive(data: NSData) {
        do {
            let json = try NSJSONSerialization
                .JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
            
            let name = json["name"] as! String
            let x = json["x"] as! CGFloat
            let y = json["y"] as! CGFloat
            
            print(json)
            
            if let robot = robots[name] {
                guard x != y && x != 0.0 else {
                    robot.removeFromParent()
                    return
                }
                
                let dist = CGPointMake(x, y)
                robot.moveTo(dist)
            } else {
                let sp = Robot(name: "robot", scale: 0.1)
                sp.position = CGPointMake(x, y)
                sp.userName = name
                sp.showName = true
                
                robots[name] = sp
                scene?.addChild(sp)
            }
            
        } catch let error as NSError {
            print(error.userInfo)
        }

    }
   
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .Portrait
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
