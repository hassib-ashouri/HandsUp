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
    static let manager = SocketManager(socketURL: URL(string:"http://handsup.blocklegion.tech:4000")!)
    static let socket = manager.defaultSocket
    
    override init(){
        super.init()
        Connection.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        Connection.socket.on("reply") {data, ack in
            print(data)
        }
        Connection.socket.connect(timeoutAfter: 1.0) {print("did not connect")}
    }
    
    static func getSocket() -> SocketIOClient{
        return Connection.socket
    }
}
