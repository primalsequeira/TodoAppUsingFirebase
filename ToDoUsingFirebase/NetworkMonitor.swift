//
//  NetworkMonitor.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 17/12/21.
//

import Foundation
import Network



class NetworkMonitor {
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
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
}
