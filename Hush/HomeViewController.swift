//
//  HomeViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/27/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
        
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
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "EnterChatRoomSegue"{
            print("Data passed over to the new controller")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRoom.count == 0 ? 2 : self.chatRoom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomNibCell.identifier, for: indexPath) as! ChatRoomNibCell
        
//        let singleConversation = self.chat
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EnterChatRoomSegue", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
}
