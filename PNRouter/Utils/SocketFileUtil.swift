//
//  SocketFileUtil.swift
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/29.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

import UIKit
//import Starscream

class SocketFileUtil: NSObject {
    @objc var socket:WebSocket? = nil
    @objc public var onConnect: (() -> Void)?
    @objc public var onDisconnect: ((Error?,String?) -> Void)?
    @objc public var receiveFileText: ((String?) -> Void)?
    @objc public var receiveFileData: ((Data?) -> Void)?
    @objc public var sendFileComplete: (() -> Void)?
    
    @objc func connect(url:String) {
        socket = WebSocket(url: URL(string: url)!, protocols: ["lws-pnr-bin"])
        socket!.disableSSLCertValidation = true
        //websocketDidConnect
        socket!.onConnect = {
            print("websocket is connected")
            self.onConnect!()
        }
        //websocketDidDisconnect
        socket!.onDisconnect = { (error: Error?) in
            print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
            self.onDisconnect!(nil,url)
           // NotificationCenter.default.post(name: Notification.Name(rawValue:SOCKET_DISCONNECT_NOTI), object:url)
            
        }
        //websocketDidReceiveMessage
        socket!.onText = {[weak self] (text: String) in
            self?.receiveFileText!(text)
        }
        
        //websocketDidReceiveData
        socket!.onData = {[weak self] (data: Data) in
            print("receive data: \(data.count)")
            self?.receiveFileData!(data)
        }
        //you could do onPong as well.
        socket!.connect()
    }
    
    @objc func disconnect() {
        socket?.disconnect()
        //socket = nil
    }
    
   @objc func send(text:String) {
        socket?.write(string: text, completion: {
            print("send text:\(text)")
        })
    }
    
    @objc func send(data:Data) {
        socket?.write(data: data, completion: { [weak self] in
           // self?.sendFileComplete!()
            print("send data:\(data.count)---time123 :\(NSDate())")
        })
    }
    
    @objc func isConnected() -> Bool {
        if (socket != nil) {
            return socket!.isConnected
        }
        return false
    }
}
