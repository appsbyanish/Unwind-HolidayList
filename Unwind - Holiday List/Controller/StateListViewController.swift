//
//  StateListViewController.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 04/11/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
import SwiftyJSON
import Alamofire

class StateListViewController: UITableViewController {
    
    let holidayListJsonURL = "https://s3.ap-south-1.amazonaws.com/holiday-list/holidays.json"
    
    let realm = try! Realm()
    
    var states: Results<State>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded StateListViewController")
        loadStates()
    }
    
    func loadStates() {
        states = realm.objects(State.self)
        
        if(states?.count == 0) {
            SVProgressHUD.show()
            
            Alamofire.request(holidayListJsonURL, method: .get).responseJSON {
                response in
                if response.result.isSuccess {
                    
                    self.parseHolidayJson(holidayListJson: JSON(response.result.value!))
                    
                    self.states = self.realm.objects(State.self)
                    
                    self.tableView.reloadData()
                }
                else {
                    print("Error parsing JSON: \(String(describing: response.result.error))")
                }
                
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func parseHolidayJson(holidayListJson: JSON) {
            
        for (_, stateJson):(String, JSON) in holidayListJson["states"] {
            
            let state = State()
            
            state.name = stateJson["name"].stringValue
            
            for (_, holidayJson):(String, JSON) in stateJson["holidays"] {
                    
                let holiday = Holiday()
                holiday.name = holidayJson["name"].stringValue
                
                // TODO: set date
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.init(abbreviation: "IST")
                dateFormatter.dateFormat = "dd/MM/yyyy"
                
                if let date = dateFormatter.date(from: holidayJson["date"].stringValue) {
                    holiday.date = date
                    
                    if state.holidays.count > 0 {
                        if let previousHoliday = state.holidays.last {
                            if holiday.date.timeIntervalSince(previousHoliday.date) <= Constants.TIME_INTERVAL_ONE_DAY {
                                holiday.cellColorHexCode = previousHoliday.cellColorHexCode
                            } else {
                                holiday.cellColorHexCode = previousHoliday.cellColorHexCode == Constants.HOLIDAY_LIST_CELL_COLOR ? Constants.HOLIDAY_LIST_CELL_COLOR_ALTERNATE : Constants.HOLIDAY_LIST_CELL_COLOR
                            }
                        }
                        
                    } else {
                        holiday.cellColorHexCode = Constants.HOLIDAY_LIST_CELL_COLOR
                    }
                }
                
                state.holidays.append(holiday)
            }
            do {
                try realm.write {
                    realm.add(state)
                }
            } catch {
                print("Error saving state: \(error)")
            }
                
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return states?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "State", for: indexPath)

        if let state = states?[indexPath.row] {
            cell.textLabel?.text = state.name
        }
       

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToHolidayList", sender: self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HolidayListController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedState = states?[indexPath.row]
        }
    }

}
