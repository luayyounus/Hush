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
        print("the ref: \(String(describing: chatRoomRef))")
    }
    
    var chatRoomRef: DatabaseReference?
    
    @IBOutlet weak var chatRoomName: UITextField!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
    
        if let name = chatRoomName?.text {
            let chatRoomAutoId = chatRoomRef?.childByAutoId()
            let singleChatRoom = [
                "name": name
            ]
            chatRoomAutoId?.setValue(singleChatRoom)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
