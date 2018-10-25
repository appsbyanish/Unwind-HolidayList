//
//  ViewController.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 25/10/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holidayListTableView: UITableView!
    
    var holidayListJson = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        holidayListTableView.delegate = self
        holidayListTableView.dataSource = self
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    


}

