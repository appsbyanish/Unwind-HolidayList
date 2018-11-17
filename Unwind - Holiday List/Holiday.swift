//
//  Holiday.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 25/10/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import Foundation
import RealmSwift

class Holiday: Object {
    
    let name: List<String> = List<String>()
    @objc dynamic var date: Date = Date()
    @objc dynamic var cellColorIndex: Int = 0
    @objc dynamic var isHidden = false
}
