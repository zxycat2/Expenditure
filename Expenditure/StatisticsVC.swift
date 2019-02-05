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
        if let context = self.container?.viewContext{
            let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
            request.predicate = NSPredicate(format: "year == %@ && month == %@", self.nowYearString! as CVarArg, self.nowMonthString! as CVarArg)
            let result = try?context.fetch(request)
            if result != nil{
                print(result?.count)
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
            if result != nil{
                print(result?.count)
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
