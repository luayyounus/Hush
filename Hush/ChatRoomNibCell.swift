//
//  ChatRoomNibCell.swift
//  Hush
//
//  Created by Luay Younus on 6/27/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit

class ChatRoomNibCell: UITableViewCell {

    @IBOutlet weak var NibCell: UIView!
    @IBOutlet weak var chatRoomName: UILabel!
    @IBOutlet weak var charRoomDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
