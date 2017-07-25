//
//  PhotoViewController.swift
//  Hush
//
//  Created by Luay Younus on 7/24/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var navBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
