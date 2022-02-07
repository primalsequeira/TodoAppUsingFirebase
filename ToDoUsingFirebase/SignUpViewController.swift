//
//  SignUpViewController.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 17/12/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: BaseViewController {

    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 22
        fname.layer.cornerRadius = 22
        fname.clipsToBounds = true
        lname.layer.cornerRadius = 22
        lname.clipsToBounds = true
        email.layer.cornerRadius = 22
        email.clipsToBounds = true
        password.layer.cornerRadius = 22
        password.clipsToBounds = true
        // MARK: Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    // MARK: Stop listening for keyboard hide/show events
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        AppUtility.lockOrientation(.portrait)
    }


    @IBAction func signUpClicked(_ sender: Any) {
        if fname.text != nil && lname.text != nil && email.text != nil && password.text != nil {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { result, error in
                if error != nil {
                    print("Error while creating user")
                }else {
                    let uid = result?.user.uid
                    let ref = Database.database().reference(withPath: "users").child(uid!).child("UserData")
                    ref.setValue(["email" : self.email.text!, "password" : self.password.text!, "firstName" : self.fname.text!, "lastName" : self.lname.text!])
                    let ok = UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    self.showAlert(title: "", message: "Registration was successful", actions: [ok])
                }
            }
        }
    }
}
