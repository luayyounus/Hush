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
    
    var chatRoomToAppend: ChatRoom?
    
    @IBOutlet weak var chatRoomName: UITextField!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
    
        if let name = chatRoomName?.text {
            let chatRoomAutoId = chatRoomRef?.childByAutoId()
            let singleChatRoom = [
                "name": name
            ]
            chatRoomAutoId?.setValue(singleChatRoom)
            chatRoomToAppend = ChatRoom(id: (chatRoomAutoId?.key)!, name: name)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    
        if segue.identifier == ChatRoomsViewController.identifier {
            guard let destination = segue.destination as? ChatRoomsViewController else { return }
            destination.chatRoom.append(chatRoomToAppend!)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
