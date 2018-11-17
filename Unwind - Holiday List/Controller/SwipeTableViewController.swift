//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Angela Yu on 13/12/2017.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var cell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.rowHeight = 80.0
        
    }
    
    
    
    //TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> HolidayTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HolidayTableViewCell", for: indexPath) as! HolidayTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .right {
            let hideAction = SwipeAction(style: .default, title: "Hide") { action, indexPath in
                self.toggleHideAction(at: indexPath, to: true)
            }
            
            // customize the action appearance
            //deleteAction.image = UIImage(named: "delete-icon")
            
            return [hideAction]
        } else {
            let unhideAction = SwipeAction(style: .default, title: "Unhide") { action, indexPath in
                self.toggleHideAction(at: indexPath, to: false)
            }
            
            // customize the action appearance
            //deleteAction.image = UIImage(named: "delete-icon")
            
            return [unhideAction]
        }
        
        
    }
    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
//        var options = SwipeTableOptions()
//        options.expansionStyle = .default
//        return options
//    }
    
    func toggleHideAction(at indexPath: IndexPath, to hide: Bool) {
        
    }
}

