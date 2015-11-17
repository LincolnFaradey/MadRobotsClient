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

class GameViewController: UIViewController, WebSocketDelegate {
    let websocket = (UIApplication.sharedApplication().delegate as! AppDelegate).websocket
    let scene = GameScene(fileNamed:"GameScene")
    var robots = [String: Robot]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        websocket.delegate = self
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        websocket.connect()
    }

    
    //MARK: WebSocketDelegate
    func websocketDidConnect(socket: WebSocket) {
        print("Connected")

        let player = [
            "name": "\(scene!.date)",
            "x": scene!.robot.position.x,
            "y": scene!.robot.position.y
        ]
        robots["\(scene!.date)"] = scene!.robot
        
        let data = try! NSJSONSerialization.dataWithJSONObject(player, options: .PrettyPrinted)
        websocket.writeData(data)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        print("recieved")
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
            let name = json["name"] as! String
            
            let x = json["x"] as! CGFloat
            let y = json["y"] as! CGFloat
            
            print(json)

            if let p = robots[name] {
                if x == y && x == 0.0 {
                    p.removeFromParent()
                    return
                }
                
                let dist = CGPointMake(x, y)
                p.moveTo(dist)
            } else {
                let sp = Robot(name: "robot", scale: 0.1)
                sp.position = CGPointMake(x, y)
                sp.userName = name
                robots[name] = sp
                sp.showName = true
                scene?.addChild(robots[name]!)
            }
            
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("written")
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
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
