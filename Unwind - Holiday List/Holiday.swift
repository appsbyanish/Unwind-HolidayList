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
    
    @objc dynamic var name: String = ""
    @objc dynamic var date: Date = Date()
    
    var parentState = LinkingObjects(fromType: State.self, property: "holidays")
    
}
