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

    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageToView: JSQPhotoMediaItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesBarsOnTap = true

        self.imageView.image = imageToView?.image
    }
    
    override var prefersStatusBarHidden: Bool {
        if self.navigationController?.isNavigationBarHidden == true {
            return true
        }
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
