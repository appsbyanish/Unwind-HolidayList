//
//  ViewController.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 25/10/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import UIKit
import RealmSwift

class HolidayListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holidayListTableView: UITableView!
    
    let realm = try! Realm()
    
    var selectedState: State? {
        didSet {
            loadHolidays()
        }
    }
    
    func loadHolidays() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loaded HolidayListViewController")
        
        holidayListTableView.delegate = self
        holidayListTableView.dataSource = self
        
        holidayListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Holiday")
    
        holidayListTableView.register(UINib(nibName: "HolidayTableViewCell", bundle: nil) , forCellReuseIdentifier: "HolidayTableViewCell")
        
        holidayListTableView.rowHeight = UITableView.automaticDimension
        holidayListTableView.estimatedRowHeight = 120.0
        
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
            
            //cell.textLabel?.text = "\(holiday.date.dayOfTheWeek()!) \(holiday.name)"
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
