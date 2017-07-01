//
//  ChatRoomsViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/27/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var chatRoomRef: DatabaseReference = Database.database().reference().child("chatRooms")
    private var chatRoomHandle: DatabaseHandle?
    var senderDisplayName: String?
    var chatRoom = [ChatRoom]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let chatRoomNib = UINib(nibName: "ChatRoomNibCell", bundle: nil)
        self.tableView.register(chatRoomNib, forCellReuseIdentifier: ChatRoomNibCell.identifier)
        startMonitoringChatRoomsUpdates()
    }
    
    private func startMonitoringChatRoomsUpdates() {
        chatRoomHandle = chatRoomRef.observe(.childAdded, with: { (snapShot) in
            let chatRoomData = snapShot.value as! Dictionary<String,Any>
            let id = snapShot.key
            if let name = chatRoomData["name"] as! String!, name.characters.count > 0 {
                self.chatRoom.append(ChatRoom(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Can not retrieve data for chatRooms")
            }
        })
    }
    
    deinit {
        if let refHandle = chatRoomHandle {
            chatRoomRef.removeObserver(withHandle: refHandle)
        }
    }
    
    //Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let chatRoom = sender as? ChatRoom {
            let conversationVC = segue.destination as! ConversationViewController
            
            conversationVC.senderDisplayName = senderDisplayName
            conversationVC.chatRoom = chatRoom
            conversationVC.chatRoomRef = chatRoomRef.child(chatRoom.id)
        }
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRoom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomNibCell.identifier, for: indexPath) as! ChatRoomNibCell
        
        cell.chatRoomName.text = chatRoom[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ConversationViewController", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
}
