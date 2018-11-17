//
//  ViewController.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 25/10/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import SwiftyJSON
import SVProgressHUD
import Alamofire

class HolidayListController: SwipeTableViewController {
    
    //@IBOutlet weak var holidayListTableView: UITableView!
    
    let holidayListJsonURL = "https://s3.ap-south-1.amazonaws.com/holiday-list/holidays.json"
    //let holidayListJsonURL = "/Users/anishgopalvenugopal/my lair/apps/Unwind - Holiday List/Unwind - Holiday List/holidays.json"
    
    let realm = try! Realm()
    
    var holidays: Results<Holiday>? //persistent data
    var holidayListToDisplay: List<Holiday> = List<Holiday>()
    
    private var isAlternateCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //holidayListTableView.delegate = self
        //holidayListTableView.dataSource = self
        
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Holiday")
        
        tableView.register(UINib(nibName: "HolidayTableViewCell", bundle: nil) , forCellReuseIdentifier: "HolidayTableViewCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.separatorStyle = .none
        
        loadHolidays()
        
        tableView.reloadData()
    }
    
    func loadHolidays() {
        holidays = realm.objects(Holiday.self)
        
        if(holidays?.count == 0) {
            SVProgressHUD.show()
            
            Alamofire.request(holidayListJsonURL, method: .get).responseJSON {
                response in
                if response.result.isSuccess {
                    
                    self.parseHolidayJson(holidayListJson: JSON(response.result.value!))
                    
                    self.holidays = self.realm.objects(Holiday.self)
                    
                    self.tableView.reloadData()
                }
                else {
                    print("Error parsing JSON: \(String(describing: response.result.error))")
                }
                
                SVProgressHUD.dismiss()
            }
        } else {
            for holiday in holidays! {
                if !holiday.isHidden {
                    holidayListToDisplay.append(holiday)
                }
            }
        }
    }
    
    func parseHolidayJson(holidayListJson: JSON) {
        
        for (_, holidayJson):(String, JSON) in holidayListJson["holidays"] {
            
            let holiday = Holiday()
            holiday.name.append(holidayJson["name"].stringValue)
            
            // TODO: set date
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.init(abbreviation: "IST")
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            if let date = dateFormatter.date(from: holidayJson["date"].stringValue) {
                holiday.date = date
                
                if holidayListToDisplay.count > 0 {
                    if let previousHoliday = holidayListToDisplay.last {
                        if holiday.date.timeIntervalSince(previousHoliday.date) == 0 {
                            do {
                                try realm.write {
                                    previousHoliday.name.append(holidayJson["name"].stringValue)
                                }
                            } catch {
                                print("Error updating holiday: \(error)")
                            }
                            continue
                        
                        } else if holiday.date.timeIntervalSince(previousHoliday.date) <= Constants.TIME_INTERVAL_ONE_DAY {
                            holiday.cellColorIndex = previousHoliday.cellColorIndex
                        } else {
                            holiday.cellColorIndex = previousHoliday.cellColorIndex == 0 ? 1 : 0
                        }
                    }
                    
                } else {
                    holiday.cellColorIndex = 0
                }
            }
            
            do {
                try realm.write {
                    realm.add(holiday)
                    holidayListToDisplay.append(holiday)
                }
            } catch {
                print("Error saving holiday: \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return holidayListToDisplay.count
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> HolidayTableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
            //tableView.dequeueReusableCell(withIdentifier: "HolidayTableViewCell", for: indexPath) as! HolidayTableViewCell

        let holiday = holidayListToDisplay[indexPath.row]
            
        cell.holidayDate.text = "\(holiday.date.dayOfTheWeek()!)"
        
        if holiday.name.count > 1 {
            cell.holidayName.text = "\(holiday.name[0]) (\(holiday.name.count - 1) more)"
        }
        else {
            cell.holidayName.text = holiday.name[0]
        }
        
        if holiday.isHidden {
            cell.holidayDate.textColor = Constants.HOLIDAY_LIST_HIDDEN_COLOR
            cell.holidayName.textColor = Constants.HOLIDAY_LIST_HIDDEN_COLOR
        } else {
            cell.holidayDate.textColor = UIColor.black
            cell.holidayName.textColor = UIColor.black
        }
        
        if(indexPath.row > 0) {

            if let previousHoliday = holidays?[indexPath.row - 1] {
                let timeDifference = holiday.date.timeIntervalSince(previousHoliday.date)

                if timeDifference == 0 {
                    cell.holidayDate.text = ""
                }
            }
        }

        cell.backgroundColor = UIColor(hexString: Constants.HOLIDAY_LIST_CELL_COLOR[holiday.cellColorIndex])
        

        return cell
    }
    
    override func hideAction(at indexPath: IndexPath, to hide: Bool) {
        if let holiday = holidays?[indexPath.row] {
            do {
                try realm.write {
                    holiday.isHidden = hide
                    //tableView.deleteRows(at: [index], with: .fade)
                }
                holidayListToDisplay.remove(at: indexPath.row)
                //tableView.deleteRows(at: [index], with: .left)
            } catch {
                print("Error saving holiday: \(error)")
            }
        }
    }
    
    @IBAction func toggleClicked(_ sender: UISwitch) {
        var index = 0
        
        if sender.isOn {
            for holiday in holidays! {
                if holiday.isHidden {
                    holidayListToDisplay.insert(holiday, at: index)
                }
                index += 1
            }
        } else {
            for holiday in holidays! {
                if holiday.isHidden {
                    holidayListToDisplay.remove(at: index)
                } else {
                    index += 1
                }
            }
        }
        
        tableView.reloadData()
    }
}

extension Date {
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM, EEE"
        return dateFormatter.string(from: self)
    }
}
