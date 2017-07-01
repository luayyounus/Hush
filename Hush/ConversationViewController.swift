//
//  ConversationViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/28/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {
    
    
    var chatRoomRef: DatabaseReference?
    var senderDisplayName: String?
    var chatRoom: ChatRoom? {
        didSet {
            title = chatRoom?.name
        }
    }
    
//    let date = Date()
//    let formatter = DateFormatter()
//    formatter.dateFormat = "EEEE MMM dd, yyyy h:mm:ss a zzz"
//    let stringDate = formatter.string(from: date)
//    
//    guard let date = chatRoomData["date"] as! String! else { return }

    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
