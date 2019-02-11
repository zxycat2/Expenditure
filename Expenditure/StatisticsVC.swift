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

class StatisticsVC: UIViewController, ChartViewDelegate, UIPopoverPresentationControllerDelegate{
    //popover适配
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    var firstTimeLoad = true
    override func viewWillAppear(_ animated: Bool) {
        //初始化
        self.selectedDateTime = Date()
        self.dateFormatterDateTimeVer.dateFormat = "yyy-MM-dd HH:mm"
        if self.firstTimeLoad{
             self.updateLocalDateTime()
            self.firstTimeLoad = false
        }
        self.generateYearCharts()
        self.generateMonthlyCharts()
    }

    func updateLocalDateTime(){
        let dateString = self.dateFormatterDateTimeVer.string(from: self.selectedDateTime!)
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
                self.setUpPieChart()
                //做作为数据源的字典
                var pieChartDic:[String:Double] = [:]
                for eachEntry in result!{
                    if pieChartDic.keys.contains(eachEntry.category!){
                        pieChartDic[eachEntry.category!] = pieChartDic[eachEntry.category!]! + Double(eachEntry.expence)
                        
                    }else{
                        pieChartDic[eachEntry.category!] = Double(eachEntry.expence)
                    }
                }
                //饼状图样式
                var allPieChartEntries = [PieChartDataEntry]();
                for key in pieChartDic.keys {
                    let entry = PieChartDataEntry.init(value: Double(pieChartDic[key]!), label: key);
                    allPieChartEntries.append(entry);
                }
                
                let dataSet = PieChartDataSet.init(values: allPieChartEntries, label: "");
                dataSet.colors = [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)]
                //设置名称和数据的位置 都在内就没有折线了哦
                dataSet.xValuePosition = .insideSlice;
                dataSet.yValuePosition = .outsideSlice;
                dataSet.sliceSpace = 1;//相邻块的距离
                dataSet.selectionShift = 6.66;//选中放大半径
                //指示折线样式
                dataSet.valueLinePart1OffsetPercentage = 0.8 //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
                dataSet.valueLinePart1Length = 0.8 //折线中第一段长度占比
                dataSet.valueLinePart2Length = 0.4 //折线中第二段长度最大占比
                dataSet.valueLineWidth = 1 //折线的粗细
                dataSet.valueLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //折线颜色
                
                let data = PieChartData.init(dataSets: [dataSet]);
                data.setValueFormatter(VDChartAxisValueFormatter.init());//格式化值（添加个%）
                data.setValueFont(UIFont.systemFont(ofSize: 10.0));
                data.setValueTextColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1));
                self.myPieChartView.data = data;
                
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
        leftAxis.drawGridLinesEnabled = false
        //图例说明样式
        self.myBarChartView.legend.enabled = false
        self.myBarChartView.legend.drawInside = false
        
        //右下角的description文字样式
//        self.myBarChartView.chartDescription?.text = "每月支出"
        //设置动画效果，可以设置X轴和Y轴的动画效果
        self.myBarChartView.animate(yAxisDuration: 2)
        //单击弹出ballon窗口显示数据
        //color:标记背景颜色， insets:text相对整个markerView的insets
        let markerView = BalloonMarker.init(color: UIColor.black.withAlphaComponent(0.5),
                                            font: UIFont.systemFont(ofSize: 30), textColor: UIColor.white, insets: UIEdgeInsets.zero)
        //最小的size
        markerView.minimumSize = CGSize.init(width: 75, height: 45)
        markerView.chartView = self.myBarChartView
        self.myBarChartView.marker = markerView
        //关于highLight
        self.myBarChartView.highlightPerTapEnabled = true
    }
    //设置饼状图
    func setUpPieChart(){
        
        //基本样式
        self.myPieChartView.setExtraOffsets(left: 20, top: 20, right: 20, bottom: 20)//设置距离四周的空隙
        self.myPieChartView.usePercentValuesEnabled = true;//是否根据所提供的数据, 将显示数据转换为百分比格式
        self.myPieChartView.dragDecelerationEnabled = false;//拖拽饼状图后是否有惯性效果
//        self.myPieChartView.drawSliceTextEnabled = true;//是否显示区块文本
        //空心饼状图样式
        self.myPieChartView.drawHoleEnabled = true;//饼状图是否是空心
        self.myPieChartView.holeRadiusPercent = 0.5;//空心半径占比
        self.myPieChartView.holeColor = UIColor.clear;//空心颜色
        self.myPieChartView.transparentCircleRadiusPercent = 0.52;//半透明空心半径占比
        self.myPieChartView.transparentCircleColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1);//半透明空心的颜色
        //实心饼状图样式
        //    self.pieChartView.drawHoleEnabled = NO;
        //饼状图中间描述
        if (self.myPieChartView.isDrawHoleEnabled == true) {
            self.myPieChartView.drawCenterTextEnabled = true;//是否显示中间文字
            //普通文本
            //        self.pieChartView.centerText = @"饼状图";//中间文字
            //富文本
            let centerText:NSMutableAttributedString = NSMutableAttributedString(string: "消费类别", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize:16), .foregroundColor:#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)])
            self.myPieChartView.centerAttributedText = centerText;
        }
        //饼状图描述
        self.myPieChartView.chartDescription?.text = "类别";
        self.myPieChartView.chartDescription?.font = UIFont.systemFont(ofSize:16)
        self.myPieChartView.chartDescription?.textColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        //饼状图图例
        self.myPieChartView.legend.enabled = true
        self.myPieChartView.legend.maxSizePercent = 1;//图例在饼状图中的大小占比, 这会影响图例的宽高
        self.myPieChartView.legend.formToTextSpace = 5;//文本间隔
        self.myPieChartView.legend.font = UIFont.systemFont(ofSize:10);//字体大小
        self.myPieChartView.legend.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);//字体颜色
        self.myPieChartView.legend.horizontalAlignment = .center;
        self.myPieChartView.legend.verticalAlignment = .bottom;//图例在饼状图中的位置
        self.myPieChartView.legend.form = .circle;//图示样式: 方形、线条、圆形
        self.myPieChartView.legend.formSize = 12;//图示大小
        //设置动画效果
        self.myPieChartView.animate(yAxisDuration: 2)
    }
    var selectedDateTime:Date? = nil
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
    @IBOutlet weak var monthYearSwictchedOutlet: UISegmentedControl!
    
    //准备segue到customPicker
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "customPicker"{
            if let destination = segue.destination as? customPickerVC{
                let myPopoverPresentaionController = destination.popoverPresentationController
                myPopoverPresentaionController?.delegate = self
                //准备picker
                destination.monthString =  self.nowMonthString
                destination.yearString = self.nowYearString
                destination.yearArray = []
                for index in 1...5{
                    destination.yearArray.append(Int(self.nowYearString!)!+index)
                    destination.yearArray.append(Int(self.nowYearString!)!-index)
                }
                destination.yearArray.append(Int(self.nowYearString!)!)
                destination.yearArray.sort()
                if self.monthYearSwictchedOutlet.selectedSegmentIndex == 0{
                    destination.mode = "monthYear"
                }else{
                    destination.mode = "yearOnly"
                }
            }
            
        }
    }
 
}
