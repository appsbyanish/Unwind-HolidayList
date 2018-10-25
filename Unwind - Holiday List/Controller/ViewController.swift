//
//  ViewController.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 25/10/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holidayListTableView: UITableView!
    
    let holidayListJsonURL = "https://s3.ap-south-1.amazonaws.com/holiday-list/holiday-list.json"
    var holidayListJson: JSON = JSON()

    var holidayListByYear: [Int : [String : [Holiday]]] = [Int : [String : [Holiday]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holidayListTableView.delegate = self
        holidayListTableView.dataSource = self
        
        holidayListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        parseHolidayListJson()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let holidayList = holidayListByYear[2018] {
            return holidayList["Maharashtra"]!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = holidayListTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = holidayListByYear[2018]!["Maharashtra"]![indexPath.row].name
        
        return cell
    }
    
    func parseHolidayListJson() {
        SVProgressHUD.show()
        
        Alamofire.request(holidayListJsonURL, method: .get).responseJSON {
            response in
            SVProgressHUD.dismiss()
            if response.result.isSuccess {
                
                self.holidayListJson = JSON(response.result.value!)
                
                for (_, yearJson):(String, JSON) in self.holidayListJson["holidaylist"] {
                    
                    var holidayListForState: [String : [Holiday]] = [String : [Holiday]]()
                    
                    for (_, stateJson):(String, JSON) in yearJson["state"] {
                        
                        for (_, monthJson):(String, JSON) in stateJson["Month"] {
                            
                            var holidayList: [Holiday] = [Holiday]()
                            
                            for (_, holidayJson):(String, JSON) in monthJson["Data"] {
                                
                                let holiday = Holiday()
                                holiday.name = holidayJson["holiday_name"].stringValue
                                holidayList.append(holiday)
                                
                            }
                            holidayListForState.updateValue(holidayList, forKey: stateJson["state_name"].stringValue)
                        }
                        self.holidayListByYear.updateValue(holidayListForState, forKey: yearJson["year"].intValue)
                    }
                }
                
                //print(self.holidayListByYear[2018]!["Maharashtra"]![0].name)
                self.holidayListTableView.reloadData()
            }
        }
    }

}

