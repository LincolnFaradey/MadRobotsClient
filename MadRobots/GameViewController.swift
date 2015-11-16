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
    var players = [String: SKSpriteNode]()
    
    
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
            "x": scene!.sprite.position.x,
            "y": scene!.sprite.position.y
        ]
        players["\(scene!.date)"] = scene!.sprite
        
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

            if let p = players[name] {
                if x == y && x == 0.0 {
                    print("remove")
                    players[name]?.removeFromParent()
                    return
                }
                let dist = CGPointMake(x, y)
                let rotation = scene!.rotateAction(players[name]!.position, direction: dist)
                let action = SKAction.moveTo(CGPointMake(x, y), duration: 1.5)
                p.runAction(SKAction.sequence([rotation, action]))
            } else {
                let sp = SKSpriteNode(imageNamed: "Spaceship")
                sp.name = "robot"
                sp.position = CGPointMake(x, y)
                sp.xScale = 0.1
                sp.yScale = 0.1
                players[name] = sp
                
                let nameLabel = SKLabelNode(fontNamed:"Chalkduster")
                nameLabel.text = name;
                nameLabel.fontSize = 25;
                nameLabel.position = CGPoint(x:CGRectGetMidX(sp.frame)/2,
                    y:CGRectGetMidY(sp.frame)/2);
                
                players[name]!.addChild(nameLabel)
                
                scene?.addChild(players[name]!)
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
