//
//  ChangePasswordViewController.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 23/12/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChangePasswordViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var confirmNewPass: UITextField!
    @IBOutlet weak var oldPass: UITextField!
    @IBOutlet weak var newPass: UITextField!
    var userId: String?
    var oldPassword: String?
    var resetEmail: String?
    @IBOutlet weak var passLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldPass.delegate = self
        newPass.delegate = self
        confirmNewPass.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        passLabel.text = ""
        let ref = Database.database().reference(withPath: "users").child(self.userId!)
        ref.observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            self.oldPassword = value?["password"] as? String ?? ""
            self.resetEmail = value?["email"] as? String ?? ""
        }
        
    }
    
    
    @IBAction func confirmbuttonClicked(_ sender: Any) {
        let ref = Database.database().reference(withPath: "users").child(self.userId!)
        if oldPass.text != nil && newPass.text != nil && confirmNewPass.text != nil {
            if oldPassword == oldPass.text {
                Auth.auth().currentUser?.updatePassword(to: confirmNewPass.text!) { error in
                  print("\(error)")
                }
                ref.updateChildValues(["password" : "\(confirmNewPass.text!)"])
                let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                self.showAlert(title: "", message: "Password was changed successfully. Log in Again.", actions: [okAction])
            } else {
                passLabel.text = "Old Password is incorrect"
            }
        }
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldDidChangeSelection(confirmNewPass)
    }
    

    
    func textFieldDidChangeSelection(_ textField: UITextField) {
    if oldPass.text != "" && newPass.text != "" && confirmNewPass.text != "" {

        if newPass.text == confirmNewPass.text {
            passLabel.text = ""
            } else {
                passLabel.text = "Password mismatch"
            }
        }
    }
    
    @IBAction func resetWithEmail(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: resetEmail!) { error in
          print("Reset email sent successfully")
        }


    }
    
}
