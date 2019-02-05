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
        , category:String, detail:String, dateTime:Date, uuid:String) -> ExEntry{
        print("try to update")
        let entry = ExEntry(context: context)
        entry.detail = detail
        entry.expence = number
        entry.dateTime = dateTime
        entry.category = category
        entry.uuid = uuid
        //更新month和year的string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd"
        let dateString = dateFormatter.string(from: dateTime)
        let monthString = dateString[dateString.index(dateString.startIndex, offsetBy: 5)..<dateString.index(dateString.startIndex, offsetBy: 7)]
        let yearString = dateString[dateString.index(dateString.startIndex, offsetBy: 0)..<dateString.index(dateString.startIndex, offsetBy: 4)]
        print(monthString)
        print(yearString)
        entry.month = String(monthString)
        entry.year = String(yearString)
        return entry
    }
}
