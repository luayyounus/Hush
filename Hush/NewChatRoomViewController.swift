//
//  NewChatRoomViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/28/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit
import Firebase

class NewChatRoomViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
private lazy var chatRoomRef: DatabaseReference = Database.database().reference().child("chatRooms")
    @IBOutlet weak var hushNameField: UITextField!
    @IBAction func doneButtonPressed(_ sender: UIButton) {
    
        if let name = hushNameField?.text {
            let newChannelRef = chatRoomRef.childByAutoId()
            let singleChatRoom = [
                "name": name
            ]
            newChannelRef.setValue(singleChatRoom)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
