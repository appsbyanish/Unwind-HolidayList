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
        //holidayListTableView.estimatedRowHeight = 120.0
        holidayListTableView.separatorStyle = .none
        
        loadHolidays()
        
        holidayListTableView.reloadData()
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
        
        //        for (_, stateJson):(String, JSON) in holidayListJson["states"] {
        //
        //            let state = State()
        //
        //            state.name = stateJson["name"].stringValue
        
        for (_, holidayJson):(String, JSON) in holidayListJson["holidays"] {
            
            let holiday = Holiday()
            holiday.name = holidayJson["name"].stringValue
            
            // TODO: set date
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.init(abbreviation: "IST")
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            if let date = dateFormatter.date(from: holidayJson["date"].stringValue) {
                holiday.date = date
                
                if holidays.count > 0 {
                    if let previousHoliday = holidays.last {
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
            cell.holidayName.text = holiday.name
            
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
            cell.backgroundColor = UIColor(hexString: holiday.cellColorHexCode)
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
