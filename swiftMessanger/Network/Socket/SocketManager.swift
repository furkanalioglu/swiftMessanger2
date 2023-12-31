//
//  SocketManager.swift
//  swiftMessanger
//
//  Created by Furkan Alioglu on 2.08.2023.
//

import Foundation
import SocketIO
import Starscream

protocol SocketIOManagerDelegate: AnyObject {
    func didReceiveMessage(message: MessageItem)
    func didReceiveGroupMessage(groupMessage: MessageItem)
    func didReceiveNewEnventNotification(groupMessage: GroupEventModelArray)
}

protocol SocketIOManagerChatDelegate: AnyObject {
    func didReceiveChatMessage(message: MessageItem)
    func didReceiveGroupChatMessage(groupMessage : MessageItem)
    func didReceiveNewEventUser(userModel: GroupEventModelArray)
    func didReceiveCurrentuserCountFromAck(itemCount: ItemCountAck)
    func didSendNewEventRequest(groupId: Int, seconds: Int,statusCode: Int)
}

struct SocketURL {
    static let baseURL: URL = {
        guard let url = URL(string: "http://ec2-18-196-242-245.eu-central-1.compute.amazonaws.com:3000/token=") else {
                    fatalError("Invalid base URL.")
                }
//        guard let url = URL(string:"ws://10.82.0.102:3000/token=") else {
//            fatalError("asdfafasd")
//        }
        return url
    }()
}


class SocketIOManager {
    
    private static var privateShared : SocketIOManager?
    
    class func shared() -> SocketIOManager { 
        guard let uwShared = privateShared else {
            privateShared = SocketIOManager()
            return privateShared!
        }
        return uwShared
    }
    
    private var manager: SocketManager?
    
    var socket: SocketIOClient?
    
    weak var delegate : SocketIOManagerDelegate?
    weak var chatDelegate : SocketIOManagerChatDelegate?
    
    private init() {}
    
    func establishConnection() {
        guard AppConfig.instance.currentUser != nil else {fatalError("SOCKET")}
                
        guard let token = UserDefaults.standard.string(forKey: userToken),
                let url = URL(string: "\(SocketURL.baseURL.absoluteString)\(token)") else {
              print("SOCKETDEBUG: Invalid token or URL.")
              return
          }
        print("SOCKETDEBUG:::: \(url)")
        
        
        let newManager = SocketManager(socketURL: url, config: [.log(true),
                                                                .forcePolling(false),
                                                                .forceWebsockets(true),
                                                                .connectParams(["token": token])

                
        ])
        
        let newSocket = newManager.defaultSocket
        self.manager = newManager
        self.socket = newSocket
        debugPrint("connecTParam", newManager.defaultSocket.manager?.socketURL ?? "")
        self.connectFunc()
        addHandlers()
    }
    
    func connectFunc() {
        guard self.socket?.status != .connected else { return }
        self.socket?.connect()
    }
    
    func closeConnection() {
        guard manager != nil,
              socket != nil else {
            print("SOCKETDEBUG::: Socket manager and/or socket is nil, aborting disconnection")
            return
        }
        
        print("SOCKETDEBUG: SOCKET DISCONNECTED")
        socket?.disconnect()
    }
    
    func sendMessage(message: String, toUser: String,type: String) {
        guard let userId = Int(toUser) else { fatalError(" USER DOES NOT EXIST ")}
        let myMessage = SentMessage(receiverId: userId, message: message,type: type)
        socket?.emit(SocketEmits.message.rawValue, myMessage.toData())        
    }
    
    //FIX LATERRR
    func sendGroupMessage(message: String, toGroup: String, type: String) {
        guard let gid = Int(toGroup) else { fatalError("group does not exist") }
        let myMessage = SentMessage(receiverId: gid, message: message,type: type)
        
        socket?.emitWithAck(SocketEmits.groupMessage.emitString, myMessage.toData()).timingOut(after: 10, callback: { data in
            guard let responseData = data[0] as? [String: Any] else {
                dump("Failed to cast to dictionary: \(data[0])")
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let decoder = JSONDecoder()
                let ackResponse = try decoder.decode(ItemCountAck.self, from: jsonData)
                self.chatDelegate?.didReceiveCurrentuserCountFromAck(itemCount: ackResponse)
            } catch let error {
                dump("Failed to decode JSON: \(error.localizedDescription)")
            }
        })
    }
    
    func sendRaceEventRequest(groupId: String, seconds: String,status: Int) {
        guard let groupId = Int(groupId) else { fatalError("Group id does not exist")}
        guard let seconds = Int(seconds) else { fatalError("Seconds does not exist")}
        let request = RaceEvent(groupId: groupId, seconds: seconds,status: status)
        
        socket?.emitWithAck(SocketEmits.status.emitString, request.toData()).timingOut(after: 10, callback: { data in
            guard let response = data[0] as? [String: Any],
                  let status = response["status"] as? Int else {
                print("Failed to parse response")
                return
            }
            self.chatDelegate?.didSendNewEventRequest(groupId: groupId, seconds: seconds,statusCode: status)
        })
    }
    
    private func addHandlers() {
        socket?.on(clientEvent: .connect) { data, _ in
            debugPrint("SOCKETDEBUG: connected to socket")
        }
        
        socket?.on(SocketListeners.message.rawValue) { (data, _) in
            print("SOCKETDEBUG: Raw message data: \(data)")
            guard let response = data[0] as? String,
                  let modeledData: MessageItem = MessageItem.parse(data: response)
            else {
                debugPrint("SOCKETDEBUG: Raw message data: \(data)" )
                return
            }
            let socketMessage = MessageItem(message: modeledData.message ,
                                            senderId: modeledData.senderId,
                                            receiverId: modeledData.receiverId,
                                            sendTime: modeledData.sendTime,
                                            type: modeledData.type)
            print("receiveddebugSOCKET: \(socketMessage)")
            self.delegate?.didReceiveMessage(message: socketMessage)
            self.chatDelegate?.didReceiveChatMessage(message: socketMessage)
        }
        
        socket?.on(SocketListeners.groupMessage.listenerString) { (data, _ ) in
            print("SOCKETDEBUG: Raw message data: \(data)")
            guard let response = data[0] as? String,
                  let modeledData: MessageItem = MessageItem.parse(data: response)
            else {
                debugPrint("SOCKETDEBUG: Raw message data: \(data)" )
                return
            }
            let socketMessage = MessageItem(message: modeledData.message ,
                                            senderId: modeledData.senderId,
                                            receiverId: modeledData.receiverId,
                                            sendTime: modeledData.sendTime,
                                            type: modeledData.type)
            print("receiveddebugSOCKET: \(socketMessage)")
            self.delegate?.didReceiveGroupMessage(groupMessage: socketMessage)
            self.chatDelegate?.didReceiveGroupChatMessage(groupMessage: socketMessage)
            
            
        
        }
        
        socket?.on(SocketListeners.event.listenerString) {(data, _) in
            guard let respose = data[0] as? String,
                  let modeledData : GroupEventModelArray = GroupEventModelArray.parse(data: respose)
            else{
                debugPrint("SOCKETDEBUG:123 Raw event data: \(data[0])" )
                return
            }
//            let newGroupEventModel = GroupEventModelArray(userId: modeledData.userId,
//                                                     itemCount: modeledData.itemCount,
//                                                     groupId: modeledData.groupId,
//                                                     carId: modeledData.carId)
            let newGroupEventArray = GroupEventModelArray(Array: modeledData.Array)
            print("EVENTDEBUG receibed model \(modeledData.Array)")
            self.chatDelegate?.didReceiveNewEventUser(userModel: newGroupEventArray)
            self.delegate?.didReceiveNewEnventNotification(groupMessage: newGroupEventArray)
        }
        
                
        socket?.on(clientEvent: .disconnect) { data, _ in
            debugPrint("disconnected")
        }
        
        socket?.on(clientEvent: .error) { err, _ in
            print("Error on connecting socket", err)
            if let error = err[0] as? String {
                print("Error",error)
            }
        }
    }
    
}


extension Decodable {
    static func parse<T: Decodable>(data: String) -> T! {
        let jsonData = data.data(using: .utf8)!
        return try? JSONDecoder().decode(T.self, from: jsonData)
    }
    
    static func parse<T: Decodable>(jsonData: Data) -> T {
        return try! JSONDecoder().decode(T.self, from: jsonData)
    }
}

enum SocketListeners: String {
    case message,groupMessage,event
    
    var listenerString : String {
        switch self {
        case .groupMessage:
            return "message:group"
        case .message:
            return "message"
        case .event:
            return "event"
        }
    }
    
}

enum SocketEmits: String {
    case message, groupMessage,status
    
    var emitString : String {
        switch self {
        case .groupMessage:
            return "message:group"
        case .message:
            return "message"
        case .status:
            return "event:status"
        }
    }
}
