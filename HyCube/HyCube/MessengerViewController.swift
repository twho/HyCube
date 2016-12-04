//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import NMessenger
import AsyncDisplayKit
import PubNub

class MessengerViewController: NMessengerViewController, PNObjectEventListener {
    
    struct MyProfile {
        static let myId = "myId"
        static let myName = "myName"
        static let myEmail = "myEmail"
        static let myPic = "myPic"
        static let myFriendsName = "myFriendsName"
        static let myFriendsId = "myFriendsId"
    }
    
    let segmentedControlPadding:CGFloat = 10
    let segmentedControlHeight: CGFloat = 30
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    private(set) var lastMessageGroup:MessageGroup? = nil
    var myName: String = ""
    var chatChannelName: String = "HyCubeChat"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myName = defaults.string(forKey: "myName")!
        navigationItem.title = "Forum"
        navigationItem.hidesBackButton = true
        appDelegate.client.addListener(self)
        appDelegate.client.subscribeToChannels([chatChannelName], withPresence: false)
        self.hideKeyboardWhenTappedAround()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let sendText = "\(myName)HYCUBEISAWESOME\(text)"
        appDelegate.client.publish(sendText, toChannel: chatChannelName, compressed: false, withCompletion: { (status) in
            if !status.isError {
                
            } else {
                
            }
        })
        //create a new text message
        let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: textContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        self.postText(newMessage, userName: myName, isIncomingMessage: false)
        
        return newMessage
    }
    
    //MARK: Helper Functions
    /**
     Posts a text to the correct message group. Creates a new message group *isIncomingMessage* is different than the last message group.
     - parameter message: The message to add
     - parameter isIncomingMessage: If the message is incoming or outgoing.
     */
    private func postText(_ message: MessageNode, userName: String, isIncomingMessage: Bool) {
        if self.lastMessageGroup == nil || self.lastMessageGroup?.isIncomingMessage == !isIncomingMessage {
            self.lastMessageGroup = self.createMessageGroup()
            
            //add avatar if incoming message
            if isIncomingMessage {
                self.lastMessageGroup?.avatarNode = self.createAvatar(userName: userName)
            }
            
            self.lastMessageGroup!.isIncomingMessage = isIncomingMessage
            self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: false)
            self.messengerView.addMessage(self.lastMessageGroup!, scrollsToMessage: true, withAnimation: isIncomingMessage ? .left : .right)
            
        } else {
            self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: true)
        }
    }
    
    /**
     Creates a new message group for *lastMessageGroup*
     -returns: MessageGroup
     */
    private func createMessageGroup()->MessageGroup {
        let newMessageGroup = MessageGroup()
        newMessageGroup.currentViewController = self
        newMessageGroup.cellPadding = self.messagePadding
        return newMessageGroup
    }
    
    /**
     Creates mock avatar with an AsyncDisplaykit *ASImageNode*.
     - returns: ASImageNode
     */
    private func createAvatar(userName: String)->ASImageNode {
        let avatar = ASImageNode()
        if(nil != defaults.data(forKey: userName)){
            avatar.image = UIImage(data: defaults.data(forKey: userName)! as Data)
        }
        avatar.backgroundColor = UIColor.lightGray
        avatar.preferredFrameSize = CGSize(width: 45, height: 45)
        avatar.layer.cornerRadius = 22.5
        avatar.clipsToBounds = true
        return avatar
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if message.data.channel != message.data.subscription {
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            // Message has been received on channel stored in message.data.channel.
        }
        
        if(chatChannelName == "\(message.data.channel)"){
            let messageArr = "\(message.data.message as! String)".components(separatedBy: "HYCUBEISAWESOME")
            if(messageArr[0] != "\(self.myName)"){
                let textContent = TextContentNode(textMessageString: messageArr[1], currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
                let newMessage = MessageNode(content: textContent)
                newMessage.cellPadding = messagePadding
                newMessage.currentViewController = self
                let senderName = messageArr[0]
                self.postText(newMessage, userName: senderName, isIncomingMessage: true)
            }
        }
    }
    
    deinit {
        print("Deinitialized")
    }
}
