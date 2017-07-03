//
//  ConversationViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/28/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ConversationViewController: UIViewController {

    var messages = [JSQMessage]()
    
    var senderDisplayName: String?
    var chatRoomRef: DatabaseReference?
    var chatRoom: ChatRoom? {
        didSet {
            self.title = chatRoom?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderDisplayName = Auth.auth().currentUser?.uid
    }
    
}
