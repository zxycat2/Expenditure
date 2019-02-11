//
//  customPickerVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/2/9.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit

extension Array where Element: Equatable{
    func index(for object: Element) -> Int? {
        var index = 0
        for element in self{
            if object == element{
                return index
            }
            index += 1
        }
        return nil
    }
}

class customPickerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let marginSize = CGFloat(bitPattern: 0)
    
    var monthString:String? = nil
    var yearString:String? = nil
    var mode:String? = nil//yearOnly or monthAndYear
    
    
    var selectedMonth:String? = nil
    var selectedYear:String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化
        self.pickerOutlet.delegate = self
        //预选择
        if self.monthString != nil{
            

        }
        self.pickerOutlet.selectRow(<#T##row: Int##Int#>, inComponent: <#T##Int#>, animated: <#T##Bool#>)

        // Do any additional setup after loading the view.
    }
    //picker delegate and data source stuff
    let monthArray = [1,2,3,4,5,6,7,8,9,10,11,12]
    var yearArray:[Int] = [1001,1002,1002,1004,1005,1006]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.mode == "yearOnly"{
            return 1
        }else{
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.mode == "yearOnly"{
            return self.yearArray.count
        }else{
            if component == 0{
                return self.monthArray.count
            }else{
                return self.yearArray.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.mode == "yearOnly"{
            return String(self.yearArray[row]) + "年"
        }else{
            if component == 0{
                return String(self.monthArray[row]) + "月"
            }else{
                return String(self.yearArray[row]) + "年"
            }
        }
        
    }
    
    @IBOutlet weak var pickerOutlet: UIPickerView!
    //更新
    //更新本地页面的选择
    func updateLocalDataAccordingToTheSelection(){
        if self.mode == "yearOnly"{
            self.yearString = String(self.yearArray[self.pickerOutlet.selectedRow(inComponent: 0)])
        }else{
            self.monthString = String(self.monthArray[self.pickerOutlet.selectedRow(inComponent: 0)])
            self.yearString = String(self.yearArray[self.pickerOutlet.selectedRow(inComponent: 1)])
        }
    }
    //更新统计页面的选择
    @IBAction func confirmButton(_ sender: UIButton) {
        self.updateLocalDataAccordingToTheSelection()
        if let statisticVC = popoverPresentationController?.delegate as? StatisticsVC{
            if self.monthString != nil{
                statisticVC.nowMonthString = self.monthString
            }
            if self.yearString != nil{
                statisticVC.nowYearString = self.yearString
            }
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLayoutSubviews() {
        if let contentSize = self.stackView?.sizeThatFits(UIView.layoutFittingCompressedSize){
            preferredContentSize = CGSize(width: contentSize.width+self.marginSize, height: contentSize.height+self.marginSize)
        }
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
