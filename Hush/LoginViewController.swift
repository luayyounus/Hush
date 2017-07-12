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
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "LoginToChatRooms", sender: self)
                }
            })
        }
        UserDefaults.standard.set(self.nameTextField.text, forKey: "userName")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVC = segue.destination as! UINavigationController
        let chatRoomVC = navVC.viewControllers.first as! ChatRoomsViewController
        chatRoomVC.senderDisplayName = self.nameTextField?.text
    }

    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
}
