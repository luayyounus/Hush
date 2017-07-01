//
//  Conversation.swift
//  Hush
//
//  Created by Luay Younus on 6/28/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import Foundation
import UIKit

class Conversation {
    let senderName: String
    let message: String
    let date: String
    
    init(senderName: String, message: String, date: String) {
        self.senderName = senderName
        self.message = message
        self.date = date
    }
}
