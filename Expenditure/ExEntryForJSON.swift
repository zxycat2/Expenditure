//
//  ExEntryForJSON.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/2/23.
//  Copyright © 2019 DoDo. All rights reserved.
//

import Foundation

struct ExEntryForJSON: Codable {
    var year:String
    var uuid:String
    var month:String
    var expence:Float
    var detail:String
    var day:String
    var dateTime:Date
    var category:String
    
    init(year:String, uuid:String, month:String, expence:Float, detail:String,
         day:String, dateTime:Date, category:String) {
        self.year = year
        self.uuid = uuid
        self.month = month
        self.expence = expence
        self.detail = detail
        self.day = day
        self.dateTime = dateTime
        self.category = category
    }
    
}
