//
//  NewHushViewController.swift
//  Hush
//
//  Created by Luay Younus on 6/28/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import UIKit

class NewHushViewController: UIViewController {


    @IBOutlet weak var hushNameField: UITextField!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let generatedHushNumber = hashValue
        print(generatedHushNumber)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
