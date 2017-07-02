//
//  LoginViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/30/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if self.nameTextField.text != "" {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let err = error{
                    print(err.localizedDescription)
                    return
                }
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
