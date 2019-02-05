//
//  StatisticsVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/2/3.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit
import Charts
import CoreData

class StatisticsVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //初始化
        self.nowDateTime = Date()
        self.dateFormatterDateTimeVer.dateFormat = "yyy-MM-dd HH:mm"
        self.updateLocalDateTime()
        self.generateYearCharts()
        self.generateMonthlyCharts()
    }

    func updateLocalDateTime(){
        let dateString = self.dateFormatterDateTimeVer.string(from: self.nowDateTime!)
        self.nowMonthString = String(dateString[dateString.index(dateString.startIndex, offsetBy: 5)..<dateString.index(dateString.startIndex, offsetBy: 7)])
        self.nowYearString = String(dateString[dateString.index(dateString.startIndex, offsetBy: 0)..<dateString.index(dateString.startIndex, offsetBy: 4)])
    }
    
    var container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    //生成月图
    func generateMonthlyCharts(){
        //query数据
        if let context = self.container?.viewContext{
            let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
            request.predicate = NSPredicate(format: "year == %@ && month == %@", self.nowYearString! as CVarArg, self.nowMonthString! as CVarArg)
            let result = try?context.fetch(request)
            if result != nil{
                //生成一个一个月的字典，默认每天都是0
                var monthDic:[Int:Float] = [:]
                //计算一个月有几天
                //计算2月有几天
                let monthInt = Int((result?.first?.month)!)
                let yearInt = Int((result?.first?.year)!)
                var numberOfDaysInFebuary = 0
                if (yearInt!%4 == 0 && yearInt!%100 != 0)||(yearInt!%100 == 0 && yearInt!%400 == 0 ){
                    numberOfDaysInFebuary = 29
                }else{
                    numberOfDaysInFebuary = 28
                }
                let monthDayList = [31, numberOfDaysInFebuary, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
                //填充字典
                for day in 1...monthDayList[monthInt!-1]{
                    monthDic[day] = 0
                }
                //进一步完成字典
                for entry in result!{
                    monthDic[Int(entry.day!)!] = Float(monthDic[Int(entry.day!)!]!) + entry.expence
                }
                //生成图
                //右下角描述，默认 “Description Label”
                self.lineChartView.chartDescription?.text = "每月支出统计"
                self.lineChartView.backgroundColor = UIColor.white
                
                
                var lineChartDataEntries: [ChartDataEntry] = []
                for day in 1...monthDayList[monthInt!-1] {
                    //每一个dataEntry表示一个数据
                    let dataEntry = ChartDataEntry(x: Double(day), y: Double(monthDic[day]!))
                    lineChartDataEntries.append(dataEntry)
                }
                
                let lineChartDataSet = LineChartDataSet(values: lineChartDataEntries, label: "月花费")
                lineChartDataSet.colors = [#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)]
                let lineChartData = LineChartData(dataSet: lineChartDataSet)
                self.lineChartView.data = lineChartData
            }else{
                //没有数据可显示
                print("no data")
            }
        }
            
    }
    //生成年图
    func generateYearCharts(){
        if let context = self.container?.viewContext{
            let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
            request.predicate = NSPredicate(format: "year == %@", self.nowYearString! as CVarArg)
            let result = try?context.fetch(request)
            //如果有数据
            if result != nil{
                
            }else{
                //如果没数据，无 能 为 力
            }
        }
    }
    var nowDateTime:Date? = nil
    var nowMonthString:String? = nil
    var nowYearString:String? = nil
    let dateFormatterDateTimeVer = DateFormatter()
    
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var pieChartVIew: UIView!
    
    
    @IBAction func timeButton(_ sender: UIButton) {
    }
    
    @IBAction func timeButtonOutlet(_ sender: Any) {
    }
    @IBAction func monthYearSwitcher(_ sender: UISegmentedControl) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
