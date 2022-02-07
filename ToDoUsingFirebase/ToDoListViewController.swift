//
//  ToDoListViewController.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 17/12/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import SDWebImage



class ToDoListViewController: BaseViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var todoTable: UITableView!
    var menuOut = false
    var todos: [Todo] = []
    var userId: String?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todoTable.reloadData()
        todoTable.delegate = self
        todoTable.dataSource = self
        activityIndicator.startAnimating()
        
        let ref = Database.database().reference(withPath: "users").child(userId!)
        ref.child("profileImage").observeSingleEvent(of: .value) { [self] snap in
            let value = snap.value as? NSDictionary
            let stringUrl = value?["profileURL"] as? String
            self.userImage.sd_setImage(with: URL(string: stringUrl ?? "https://drive.google.com/file/d/1uMrXlVDhpUwi0gVDzL1II1MSAr6JGjBP/view?usp=sharing"), completed: nil)
        }
        ref.child("UserData").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            let firstname = value?["firstName"] as? String ?? ""
            let lastname = value?["lastName"] as? String ?? ""
            self.userName.text = "    Hello! \(firstname) \(lastname)"
        }

        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(ToDoListViewController.openGallery(tapGesture:)))
        userImage.isUserInteractionEnabled =  true
        userImage.addGestureRecognizer(tapGesture)

    }
    

    
    @objc func openGallery(tapGesture: UITapGestureRecognizer) {
        print("Hello")
        setupImagePicker()
    }

    @IBAction func menuClicked(_ sender: Any) {
            if menuOut == false {
                leading.constant = 300
                trailing.constant = 0
                menuOut = true
            } else {
                leading.constant = 0
                trailing.constant = 0
                menuOut = false
            }
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:  {
                self.view.layoutIfNeeded()
            }) { (animationComplete) in
                print("Animation completed")
            }
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
        }catch let signoutError {
            let alert = UIAlertController(title: "Error", message: "\(signoutError.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as? ChangePasswordViewController {
            controller.userId = self.userId
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
            print("\(error)")
          } else {
              let ref = Database.database().reference(withPath: "users").child(self.userId!)
              ref.removeValue()
              let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
                  self.navigationController?.popToRootViewController(animated: true)
              })
              self.showAlert(title: "Alert", message: "User account successfully deleted", actions: [okAction])
          }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

       if let currentUser = Auth.auth().currentUser {
            currentUser.getIDTokenForcingRefresh(true) { string, error in
                if let error = error {
                    print("User doesnt exist")
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.showAlert(title: "Alert", message: "User account is deleted. Sign in again.", actions: [okAction])
                    
                } else {
                    self.loadTodos()
                }
            }
        }
    }

    
    func loadTodos() {
        todos = []
        let ref = Database.database().reference(withPath: "users").child(userId!).child("todos")
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                let Todouuid = child.key
                let todoref = ref.child(Todouuid)
                todoref.observeSingleEvent(of: .value) { (todosnapshot) in
                    for child2 in todosnapshot.children.allObjects as! [DataSnapshot] {
                        let TodoTitle = child2.key
                        let TodoDescrip = child2.value as? String
                        self.todos.append(Todo(uuid: Todouuid, todoTitle: TodoTitle, todoDescrip: (TodoDescrip)!))
                        self.activityIndicator.stopAnimating()
                        self.todoTable.reloadData()
                    }
                    
 
                }
                
            }
        }
        self.activityIndicator.stopAnimating()
                 
    }

    @IBAction func plusClicked(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToDoViewController") as? ToDoViewController {
            controller.userId = self.userId
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    

}
extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTableViewID", for: indexPath) as! TodoTableView
        cell.todoTitle.text = todos[indexPath.row].todoTitle
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.todoTable.reloadData()
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToDoViewController") as? ToDoViewController {
            controller.descData = todos[indexPath.row].todoDescrip
            controller.titleData = todos[indexPath.row].todoTitle
            controller.userId = self.userId
            controller.todo = self.todos[indexPath.row]
            controller.uid = todos[indexPath.row].uuid
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (ac: UIContextualAction, view: UIView, success: @escaping(Bool) -> Void) in
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToDoViewController") as? ToDoViewController {
                controller.titleData = self.todos[indexPath.row].todoTitle
                controller.descData = self.todos[indexPath.row].todoDescrip
                controller.userId = self.userId
                controller.todo = self.todos[indexPath.row]
                controller.uid = self.todos[indexPath.row].uuid
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        }
        edit.backgroundColor = .white
        edit.image = UIImage(named: "edit")
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { (ac: UIContextualAction, view: UIView, success: @escaping(Bool) -> Void) in
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                let ref = Database.database().reference(withPath: "users").child(self.userId!).child("todos").child("\(self.todos[indexPath.row].uuid)")
                ref.removeValue()
                self.loadTodos()
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                self.loadTodos()
            }
            
            self.showAlert(title: "Delete", message: "Are you sure you want to delete?", actions: [yesAction, cancelAction])
            

        }
        delete.backgroundColor = .white
        delete.image = UIImage(named: "delete")
        let config = UISwipeActionsConfiguration(actions: [edit, delete])
        return config
    }
    
    
    
}

extension ToDoListViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        userImage.image = image
        self.dismiss(animated: true) {
            self.uploadImage(self.userImage.image!) { url in
                self.saveImage(profileUrl: url!) { url in
                    if url != nil {
                        print("Yeah")
                    }
                }
                if url != nil {
                    print("Yeah")
                }
            }
        }
    }
    
}

extension ToDoListViewController {
    
    func uploadImage(_ image: UIImage, completion: @escaping((_ url: URL?)-> ())) {
        let storagRef = Storage.storage().reference().child(userId!).child("myimage.png")
        let imgData = userImage.image?.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storagRef.putData(imgData!, metadata: metaData) { (metadata, err) in
            if err == nil {
                print("success")
                storagRef.downloadURL { (url, err) in
                    completion(url!)
                }
            } else {
                print("error while saving image")
                completion(nil)
            }
        }
    }
    
    func saveImage(profileUrl: URL, completion: @escaping((_ url: URL?)-> ())){
        let ref = Database.database().reference(withPath: "users").child(userId!).child("profileImage")
        ref.setValue(["profileURL": profileUrl.absoluteString] as [String: Any])

    }
}
