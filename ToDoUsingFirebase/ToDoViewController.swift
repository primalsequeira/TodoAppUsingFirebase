//
//  ToDoViewController.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 17/12/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class ToDoViewController: BaseViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var DesLength: UILabel!
    @IBOutlet weak var todoDescrip: UITextView!
    @IBOutlet weak var todoTitle: UITextField!

    var userId: String?
    var uid: String?
    var todo : Todo?
    var isitEditing = false
    
    var titleData: String?
    var descData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        todoDescrip.layer.cornerRadius = 10
        todoDescrip.clipsToBounds = true
        todoTitle.layer.cornerRadius = 10
        todoTitle.clipsToBounds = true
        todoTitle.delegate = self
        todoDescrip.delegate = self
        Utility.textTitle = todo?.todoTitle ?? ""
        self.updateCharacterCount()
        self.setData()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        AppUtility.lockOrientation(.portrait)
        textViewDidChange(todoDescrip)
        if let currentUser = Auth.auth().currentUser {
            currentUser.getIDTokenForcingRefresh(true) { string, error in
                if error != nil {
                    print("User doesnt exist")
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.showAlert(title: "Alert", message: "User account is deleted. Sign in again.", actions: [okAction])
                
                }
            }
        }
    }
    
    func updateCharacterCount() {
        guard let textDescriptionCount = todoDescrip?.text.utf16.count else { return }
        self.DesLength.text = "\((0) + textDescriptionCount)/150"

    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
       if(textView == todoDescrip){
          return textView.text.utf16.count +  (text.utf16.count - range.length) <= 150
       }
       return false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCount()
    }
    
    func setData() {
        if let data = titleData {
            self.todoTitle.text = data
            isitEditing = true
        }
        if let data = descData {
            self.todoDescrip.text = data
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        Utility.textTitle = textField.text!
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        Utility.textDesc = textView.text!
    }

    @IBAction func saveClicked(_ sender: Any) {
        textViewShouldEndEditing(todoDescrip)
        if !isitEditing {
            let uuid = UUID().uuidString
            let ref = Database.database().reference(withPath: "users").child(userId!).child("todos").child("\(uuid)")
            ref.setValue(["\(Utility.textTitle)" : "\(Utility.textDesc)"])
        } else {
            let ref = Database.database().reference(withPath: "users").child(userId!).child("todos").child(uid!)
            ref.updateChildValues(["\(Utility.textTitle)" : "\(Utility.textDesc)"])
        }
        
        
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToDoListViewController") as? ToDoListViewController {
        controller.userId = self.userId
        self.navigationController?.popViewController(animated: true)
        }
    }
    
}
