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

class StatisticsVC: UIViewController, ChartViewDelegate{
    
    
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
            print(result?.count)
            if result?.count ?? 0 > 0{
                //--------------------------------支出折线图--------
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
                self.setUpTheBarChart()
                //柱状图数据
                var dataEntries: [BarChartDataEntry] = []
                for day in 1 ... monthDayList[monthInt!-1] {
                    //每一个dataEntry表示一个柱形数据，如 (0,1000) 表示第一个柱形的值为1000
                    let dataEntry = BarChartDataEntry.init(x: Double(day), y: Double(monthDic[day]!))
                    dataEntries.append(dataEntry)
                }
                
                let barChartDataSet = BarChartDataSet(values: dataEntries, label: "支出")
                //样式设置
                //显示的数值的颜色，可以多个颜色
                barChartDataSet.valueColors = [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
                //是否显示数值
                barChartDataSet.drawValuesEnabled = true
                // 边界线设置
                barChartDataSet.barBorderWidth = 1
                barChartDataSet.barBorderColor = UIColor.black
                // 柱形颜色
                barChartDataSet.colors = [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
                // 选中的高亮设置
//                barChartDataSet.highlightColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//                barChartDataSet.highlightAlpha = 1
//                barChartDataSet.highlightLineDashLengths = [4,2]
//                barChartDataSet.highlightLineWidth = 2
//                barChartDataSet.highlightEnabled = true
                
                let barChartData = BarChartData(dataSet: barChartDataSet)
                
                //柱形数据
                self.myBarChartView.data = barChartData
                //--------------------------------类别 饼图
                
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
            if result?.count ?? 0 > 0{
                //做一个字典，每月默认值0
                var yearDic:[Int:Double] = [:]
            }else{
                //如果没数据，无 能 为 力
            }
        }
    }
    //设置柱状图
    func setUpTheBarChart(){
        self.myBarChartView.delegate = self;//设置代理
        //基本样式
        self.myBarChartView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.myBarChartView.noDataText = "暂无数据";//没有数据时的文字提示
        self.myBarChartView.drawValueAboveBarEnabled = true;//数值显示在柱形的上面还是下面
        self.myBarChartView.highlightPerTapEnabled = false;//点击柱形图是否显示箭头
        self.myBarChartView.drawBarShadowEnabled = false;//是否绘制柱形的阴影背景
        
        //交互设置
        self.myBarChartView.scaleYEnabled = true;//Y轴缩放
        self.myBarChartView.scaleXEnabled = true;//X轴缩放
        self.myBarChartView.doubleTapToZoomEnabled = false;//双击缩放
        self.myBarChartView.dragEnabled = true;//启用拖拽图表
        self.myBarChartView.dragDecelerationEnabled = false;//拖拽后是否有惯性效果
        self.myBarChartView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        
        //X轴样式
        let xAxis = self.myBarChartView.xAxis;
        xAxis.axisLineWidth = 1;//设置X轴线宽
        xAxis.labelPosition = XAxis.LabelPosition.bottom;//X轴的显示位置，默认是显示在上面的
        xAxis.drawGridLinesEnabled = false;//不绘制网格线
        xAxis.labelTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);//label文字颜色
        
        //右边Y轴样式
        self.myBarChartView.rightAxis.enabled = false;//不绘制右边轴
        
        //左边Y轴样式
        let leftAxis = self.myBarChartView.leftAxis;//获取左边Y轴
        leftAxis.labelCount = 5;//Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.forceLabelsEnabled = false;//不强制绘制制定数量的label
        leftAxis.axisMinimum = 0;//设置Y轴的最小值
        leftAxis.inverted = false;//是否将Y轴进行上下翻转
        leftAxis.axisLineWidth = 0.5;//Y轴线宽
        leftAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)//Y轴颜色
        //                leftAxis.valueFormatter = IAxisValueFormatter.in//自定义格式
        //                leftAxis.valueFormatter.positiveSuffix = @" $";//数字后缀单位
        leftAxis.labelPosition = YAxis.LabelPosition.outsideChart;//label位置
        leftAxis.labelTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);//文字颜色
        //网格线样式
        //                leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
        //                leftAxis.gridColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];//网格线颜色
        //                leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
        leftAxis.drawGridLinesEnabled = false
        //添加限制线
        //                ChartLimitLine *limitLine = [[ChartLimitLine alloc] initWithLimit:80 label:@"限制线"];
        //                limitLine.lineWidth = 2;
        //                limitLine.lineColor = [UIColor greenColor];
        //                limitLine.lineDashLengths = @[@5.0f, @5.0f];//虚线样式
        //                limitLine.labelPosition = ChartLimitLabelPositionRightTop;//位置
        //                [leftAxis addLimitLine:limitLine];//添加到Y轴上
        //                leftAxis.drawLimitLinesBehindDataEnabled = YES;//设置限制线绘制在柱形图的后面
        //图例说明样式
        self.myBarChartView.legend.enabled = true
        self.myBarChartView.legend.drawInside = false
        
        //右下角的description文字样式
//        self.myBarChartView.chartDescription?.text = "每月支出"
        //设置动画效果，可以设置X轴和Y轴的动画效果
        self.myBarChartView.animate(yAxisDuration: 2)
    }
    var nowDateTime:Date? = nil
    var nowMonthString:String? = nil
    var nowYearString:String? = nil
    let dateFormatterDateTimeVer = DateFormatter()
    
    
    
    
    @IBOutlet weak var myBarChartView: BarChartView!
    
    @IBOutlet weak var myPieChartView: PieChartView!
    
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
