//
//  ConnectionManager.swift
//  MadRobots
//
//  Created by Andrei Nechaev on 11/18/15.
//  Copyright © 2015 RoboCrowds. All rights reserved.
//

import Starscream

protocol ConnectionManagerDelegate {
    func connected();
    func disconnected(error: NSError?);
    
    func managerDidReceive(data: NSData);
}

class ConnectionManager {
    static let sharedInstance = ConnectionManager()
    //192.168.0.195
    let websocket = WebSocket(url: NSURL(string: "ws://188.226.135.225:8080")!)
    var delegate: ConnectionManagerDelegate?
    
    private init() {
        websocket.onConnect = {
            self.delegate?.connected()
        }
        
        websocket.onDisconnect = { error in
            self.delegate?.disconnected(error)
        }
        
        websocket.onData = { data in
            self.delegate?.managerDidReceive(data)
        }
        
        websocket.onText = { text in
            let data = text.dataUsingEncoding(NSUTF8StringEncoding)!
            self.delegate?.managerDidReceive(data)
        }
        
        websocket.connect()
    }
    
    func send(data: NSData) {
        if !websocket.isConnected {
            print("Connection is not established")
            return
        }
        websocket.writeData(data)
    }
    
    func establishConnection() {
        websocket.connect()
    }
    
    func closeConnection() {
        websocket.disconnect()
    }
}
