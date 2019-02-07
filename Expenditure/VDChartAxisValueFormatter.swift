//
//  VDChartAxisValueFormatter.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/2/7.
//  Copyright © 2019 DoDo. All rights reserved.
//

import Foundation
import Charts

class VDChartAxisValueFormatter: IValueFormatter{
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String.init(format: "%.2f%%", value);
    }
    
    
}
