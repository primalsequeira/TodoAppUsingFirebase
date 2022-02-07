//
//  LoginViewController.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 17/12/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: BaseViewController , UITextFieldDelegate{

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var uid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 22
        email.layer.cornerRadius = 22
        email.clipsToBounds = true
        password.layer.cornerRadius = 22
        password.clipsToBounds = true
        email.delegate = self
        password.delegate = self
        
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
    
    func hideKeyboard() {
        password.resignFirstResponder()
    }


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        AppUtility.lockOrientation(.portrait)
        
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        hideKeyboard()
        if email.text != nil && password.text != nil {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { result, error in
                if error != nil {
                    print("Error while logging in..")
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    self.showAlert(title: "Alert", message: "Error while logging in", actions: [ok])
                } else {
                    self.uid = (result?.user.uid)!
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToDoListViewController") as? ToDoListViewController
                    controller?.userId = self.uid
                    self.navigationController?.pushViewController(controller!, animated: true)
                    
                }
            }
        }
    }

}
