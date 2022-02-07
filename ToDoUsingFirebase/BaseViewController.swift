//
//  BaseViewController.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 17/12/21.
//

import UIKit
import Network

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    class func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    print("Internet Connected")
                }
                
            } else {
                DispatchQueue.main.async {
                    print("No internet")
                    //showAlert(title: "WARNING", message: "No Internet")

                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func showAlert(title: String?, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            alert.addAction(action)
        }
       // alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}


