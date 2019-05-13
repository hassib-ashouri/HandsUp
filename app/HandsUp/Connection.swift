//
//  Connection.swift
//  HandsUp
//
//  Copyright © 2019 Team07. All rights reserved.
//

import Foundation
import SocketIO

class Connection: NSObject {
    static let manager = SocketManager(socketURL: URL(string:"http://localhost:4000")!)
    static let socket = manager.defaultSocket 
    static var classCode:String = "1234"
    /**
        initialize the socket with the proper listeners for the events.
    */
    override init(){
        super.init()
        // log on connection
        Connection.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        // on repluy prin the reply
        Connection.socket.on("reply") {data, ack in
            print(data)
        }
        // parse the code of the class when received
        Connection.socket.on("code") {data, ack in
            if let obj = data[0] as? NSDictionary {
                Connection.classCode = obj["code"] as! String
                SessionViewController.joined = .joined
            }
        }
        // process the feedback of the server if the class exists
        Connection.socket.on("join confirmed") {data, ack in
            if let obj = data[0] as? NSDictionary {
                if(obj["didJoin"] as! Bool == true)
                {
                    SessionViewController.joined = .joined
                }
                else
                {
                    SessionViewController.joined = .problem
                }
            }
        }
        Connection.socket.connect(timeoutAfter: 1.0) {print("did not connect")}
    }
    /**
        a getter for the current socket.
     */
    static func getSocket() -> SocketIOClient{
        return Connection.socket
    }
}
