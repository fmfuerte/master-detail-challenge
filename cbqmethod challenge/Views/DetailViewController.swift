//
//  DetailViewController.swift
//  cbqmethod challenge
//
//  Created by Francis Martin Fuerte on 5/24/21.
//

import UIKit

class DetailViewController: UIViewController, UserSelectionDelegate {
    
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var completedSwitch: UISwitch!
    
    
    var user: UserList? { //if user is set call refreshUI
      didSet {
        refreshUI()
      }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    func refreshUI() { //sets new values 
      loadViewIfNeeded()
        userLabel.text = user?.userId.description
        idLabel.text = user?.id.description
        titleTextField.text = user?.title
    completedSwitch.isOn = user?.completed == true ? true : false
    }
    
    //delegate call, sets the user
    func userSelected(_ newUser: UserList) {
        user = newUser
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
