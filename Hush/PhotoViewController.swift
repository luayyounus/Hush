//
//  PhotoViewController.swift
//  Hush
//
//  Created by Luay Younus on 7/24/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class PhotoViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageFromConversation: JSQPhotoMediaItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = imageFromConversation?.image
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
