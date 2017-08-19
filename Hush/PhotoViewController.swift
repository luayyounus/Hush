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
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var imageToView: JSQPhotoMediaItem?
    var imageTappedIndicator: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = imageToView?.image
        self.imageView.isUserInteractionEnabled = true
        self.navigationBarTitle.title = "1 of ?"
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func imageTappedOnce(_ sender: UITapGestureRecognizer) {
        if self.imageTappedIndicator {
            self.imageTappedIndicator = false
            self.navigationBar.isHidden = false
            self.toolbar.isHidden = false
            return
        }
        self.imageTappedIndicator = true
        self.navigationBar.isHidden = true
        self.toolbar.isHidden = true
    }
}
