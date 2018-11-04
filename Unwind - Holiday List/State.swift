//
//  State.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 04/11/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class State: Object {
    
    @objc dynamic var name = ""
    
    let holidays = List<Holiday>()
    
}
