//
//  TodoTableView.swift
//  ToDoUsingFirebase
//
//  Created by Sequeira, Primal Carol on 17/12/21.
//

import UIKit

class TodoTableView: UITableViewCell {
    
    @IBOutlet weak var todoTitle: UILabel!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var todoCreationDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    override func layoutSubviews() {
        innerView.layer.cornerRadius = 20.0
        innerView.layer.shadowColor = UIColor.gray.cgColor
        innerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        innerView.layer.shadowRadius = 12.0
        innerView.layer.shadowOpacity = 0.7

        }

}
