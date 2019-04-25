//
//  Connection.swift
//  HandsUp
//
//  Created by Yazan Arafeh on 4/24/19.
//  Copyright © 2019 Team07. All rights reserved.
//

import Foundation
import SocketIO

class Connection: NSObject {
    let manager:SocketManager
    let socket:SocketIOClient
    
    override init(){
        self.manager = SocketManager(socketURL: URL(string:"http://handsup.blocklegion.tech:4000")!)
        self.socket = self.manager.defaultSocket
        socket.on("reply"){data, ack in
            let mess = data[0]
            print(mess)
        }
        self.socket.connect()
    }
    
    func isActive() -> Bool {
        if socket == nil{
            return false
        }
        return true
    }
    
    func getSocket() -> SocketIOClient{
        return socket
    }
}
