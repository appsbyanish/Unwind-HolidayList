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

class HolidayListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holidayListTableView: UITableView!
    
    let realm = try! Realm()
    private let TIME_INTERVAL_ONE_DAY: Double = 86400
    
//    private var holidaysToDisplay: List<Holiday> = List<Holiday>()
    
    var selectedState: State? {
        didSet {
            loadHolidays()
        }
    }
    
    private var isAlternateCell = false
    
    func loadHolidays() {
//        if let holidays = selectedState?.holidays {
//            for holiday in holidays {
//                if holidays.count != 0 {
//                    if let previousHoliday = holidays.last {
//                        let timeDifference = holiday.date.timeIntervalSince(previousHoliday.date)
//
//                        if timeDifference == 0 {
//                            previousHoliday.name.append(", \(holiday.name)")
//                        }
//                        else {
//                            holidaysToDisplay.append(holiday)
//                        }
//                    }
//                }
//                else {
//                    holidaysToDisplay.append(holiday)
//                }
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loaded HolidayListViewController")
        
        holidayListTableView.delegate = self
        holidayListTableView.dataSource = self
        
        holidayListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Holiday")
    
        holidayListTableView.register(UINib(nibName: "HolidayTableViewCell", bundle: nil) , forCellReuseIdentifier: "HolidayTableViewCell")
        
        holidayListTableView.rowHeight = UITableView.automaticDimension
        //holidayListTableView.estimatedRowHeight = 120.0
        holidayListTableView.separatorStyle = .none
        
        holidayListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return selectedState?.holidays.count ?? 1
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = holidayListTableView.dequeueReusableCell(withIdentifier: "HolidayTableViewCell", for: indexPath) as! HolidayTableViewCell

        if let holiday = selectedState?.holidays[indexPath.row] {
            
            cell.holidayDate.text = "\(holiday.date.dayOfTheWeek()!)"
            cell.holidayName.text = holiday.name
            
            var isNextHoliday = false
            
            if(indexPath.row > 0) {
                
                if let previousHoliday = selectedState?.holidays[indexPath.row - 1] {
                    let timeDifference = holiday.date.timeIntervalSince(previousHoliday.date)
                    
                    if timeDifference == 0 {
                        cell.holidayDate.text = ""
                    }
                    
                    isNextHoliday = (timeDifference <= TIME_INTERVAL_ONE_DAY)
                }
            }
            
            if isNextHoliday {
                isAlternateCell = !isAlternateCell
            }
            
            if isAlternateCell {
                cell.backgroundColor = UIColor(hexString: FlatSand().hexValue())
            } else {
                cell.backgroundColor = UIColor(hexString: FlatSand().hexValue())?.darken(byPercentage: 0.1)
            }
            isAlternateCell = !isAlternateCell
            
        }

        return cell
    }
}

extension Date {
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd - MMM, EEE"
        return dateFormatter.string(from: self)
    }
}
