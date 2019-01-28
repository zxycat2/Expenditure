//
//  Entry.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/22.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit
import CoreData

class ExEntry: NSManagedObject {
    class func updateDatabase(in context:NSManagedObjectContext, number:Float
        , category:String, detail:String, dateTime:Date) -> ExEntry{
        print("try to update")
        let entry = ExEntry(context: context)
        entry.detail = detail
        entry.expence = number
        entry.dateTime = dateTime
        entry.category = category
        entry.uuid = NSUUID().uuidString
        print("created!")
        return entry
    }
}
