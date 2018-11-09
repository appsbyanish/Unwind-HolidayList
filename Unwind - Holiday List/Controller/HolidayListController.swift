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

class HolidayListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holidayListTableView: UITableView!
    
    let holidayListJsonURL = "https://s3.ap-south-1.amazonaws.com/holiday-list/holidays.json"
    //let holidayListJsonURL = "/Users/anishgopalvenugopal/my lair/apps/Unwind - Holiday List/Unwind - Holiday List/holidays.json"
    
    let realm = try! Realm()
    
    var holidays: Results<Holiday>?
    
    private var isAlternateCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holidayListTableView.delegate = self
        holidayListTableView.dataSource = self
        
        holidayListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Holiday")
        
        holidayListTableView.register(UINib(nibName: "HolidayTableViewCell", bundle: nil) , forCellReuseIdentifier: "HolidayTableViewCell")
        
        holidayListTableView.rowHeight = UITableView.automaticDimension
        holidayListTableView.estimatedRowHeight = 100.0
        holidayListTableView.separatorStyle = .none
        
        loadHolidays()
        
        holidayListTableView.reloadData()
    }
    
    func loadHolidays() {
        holidays = realm.objects(Holiday.self)
        
        if(holidays?.count == 0) {
            SVProgressHUD.show()
            /*
            if let path = Bundle.main.path(forResource: "holidays.json", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    
                    self.parseHolidayJson(holidayListJson: JSON(data))
                    
                    self.holidays = self.realm.objects(Holiday.self)
                    
                    self.holidayListTableView.reloadData()
                    
                } catch {
                    print("Error reading json file from disc: \(error)")
                }
            }
            SVProgressHUD.dismiss()
            */
            
            Alamofire.request(holidayListJsonURL, method: .get).responseJSON {
                response in
                if response.result.isSuccess {
                    
                    self.parseHolidayJson(holidayListJson: JSON(response.result.value!))
                    
                    self.holidays = self.realm.objects(Holiday.self)
                    
                    self.holidayListTableView.reloadData()
                }
                else {
                    print("Error parsing JSON: \(String(describing: response.result.error))")
                }
                
                SVProgressHUD.dismiss()
            }
            
        }
    }
    
    func parseHolidayJson(holidayListJson: JSON) {
        
        let holidays = List<Holiday>()
        
        for (_, holidayJson):(String, JSON) in holidayListJson["holidays"] {
            
            let holiday = Holiday()
            holiday.name.append(holidayJson["name"].stringValue)
            
            // TODO: set date
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.init(abbreviation: "IST")
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            if let date = dateFormatter.date(from: holidayJson["date"].stringValue) {
                holiday.date = date
                
                if holidays.count > 0 {
                    if let previousHoliday = holidays.last {
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
                    holidays.append(holiday)
                }
            } catch {
                print("Error saving holiday: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return holidays?.count ?? 1
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = holidayListTableView.dequeueReusableCell(withIdentifier: "HolidayTableViewCell", for: indexPath) as! HolidayTableViewCell

        if let holiday = holidays?[indexPath.row] {
            
            cell.holidayDate.text = "\(holiday.date.dayOfTheWeek()!)"
            
            if holiday.name.count > 1 {
                cell.holidayName.text = "\(holiday.name[0]) (\(holiday.name.count - 1) more)"
            }
            else {
                cell.holidayName.text = holiday.name[0]
            }
            
//            var isNextHoliday = false
//
            if(indexPath.row > 0) {

                if let previousHoliday = holidays?[indexPath.row - 1] {
                    let timeDifference = holiday.date.timeIntervalSince(previousHoliday.date)

                    if timeDifference == 0 {
                        cell.holidayDate.text = ""
                    }
                }
            }
//
//            if isNextHoliday {
//                isAlternateCell = !isAlternateCell
//            }
            
//            if isAlternateCell {
//                cell.backgroundColor = UIColor(hexString: FlatSand().hexValue())?.darken(byPercentage: 0.1) //#D5C59F
//            } else {
//                cell.backgroundColor = UIColor(hexString: FlatSand().hexValue()) //#EFDDB3
//            }
//            isAlternateCell = !isAlternateCell
            cell.backgroundColor = UIColor(hexString: Constants.HOLIDAY_LIST_CELL_COLOR[holiday.cellColorIndex])
        }

        return cell
    }
}

extension Date {
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM, EEE"
        return dateFormatter.string(from: self)
    }
}
