//
//  AddingVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/22.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit
import CoreData



class AddingVC: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var expenceNumberTextField: UITextField!
    
    @IBOutlet weak var datePickerOutlet: UIButton!
    
    @IBAction func datePickerButton(_ sender: UIButton) {
    }
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        self.allSortsOfUpdating()
    }
    
    func allSortsOfUpdating(){
        self.updateExpenceAndDetail()
        self.updateDatebase()
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    var isModifyingExistingEntry = false
    
    
    //单击函数
    @objc func singelTabpFunction(sender:UITapGestureRecognizer){
        self.textField.resignFirstResponder()
        self.expenceNumberTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化delegate
        self.textField.delegate = self
        self.expenceNumberTextField.delegate = self
        self.expenceNumberTextField.delegate = self
        //加入单击收回键盘手势
        let singleTapOnBaseViewGesture = UITapGestureRecognizer(target: self, action: #selector(singelTabpFunction))
        self.view.addGestureRecognizer(singleTapOnBaseViewGesture)
        //把textField放到最上层
        self.view.bringSubviewToFront(self.textField)
        //设置监视键盘位置
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardPositionDidChange(_:)),name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //直接弹出输入金额的键盘
        self.expenceNumberTextField.becomeFirstResponder()
        //
        self.dateFormatterDateVer.dateFormat = "yyy-MM-dd"
        
    }
    var dateFormatterDateVer = DateFormatter()
    
    //在监视到键盘变化后call的函数，把textView上移（或上移，具体根据textfield位置而定）
    @objc func keyboardPositionDidChange(_ notification:Notification){
        if self.textField.isFirstResponder{
            let info  = notification.userInfo
            let keyboardRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            if keyboardRect.origin.y == UIScreen.main.bounds.height{
                //键盘消失了
                UIView.animate(withDuration: 0.3, animations: {
                    self.textField.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: nil)
            }else{
                //键盘出现了
                let textfiledBottom = self.textField.frame.maxY
                let offSetY = keyboardRect.origin.y - textfiledBottom-10
                print("textbottom: ")
                print(textfiledBottom)
                print("K origin y: ")
                print(keyboardRect.origin.y)
                UIView.animate(withDuration: 0.3, animations: {
                    self.textField.transform = CGAffineTransform(translationX: 0, y: offSetY)
                }, completion: nil)
                print("textfield end anime bottom")
                print(self.textField.frame.maxY)
            }
        }
    }
    //textField相关
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("should return")
        self.textField.resignFirstResponder()
        if textField == self.textField{
            self.allSortsOfUpdating()
        }
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("end editting")
//        self.updateExpenceAndDetail()
//    }
    //把两个textFiled的值给本地变量
    func updateExpenceAndDetail(){
        if self.textField.text != ""{
            self.detail = self.textField.text!
            print(self.detail)
        }
        if self.expenceNumberTextField.text != ""{
            self.expenceNumber = Float(self.expenceNumberTextField.text!)!
            print(self.expenceNumber)
        }
    }
    var container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    //更新数据库
    func updateDatebase(){
        if self.isModifyingExistingEntry {
            print("is modifying existing entry")
        }else{
            self.container?.performBackgroundTask{context in
                _ = ExEntry.updateDatabase(in: context, number: self.expenceNumber, category: self.category, detail: self.detail, dateTime: self.selectedDate, uuid:self.uuid)
                try? context.save()
            }
        }
    }
    //花费数字，备注，类别
    //类别暂时还没有做！
    var expenceNumber = Float(0)
    var detail = ""
    var category = "渡渡鸟"
    var uuid = NSUUID().uuidString
    
    
    @IBOutlet weak var textField: UITextField!
    
   
    //准备datePicker popover的segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DatePickerVC{
            let myPopoverPresentaionController = destination.popoverPresentationController
            myPopoverPresentaionController?.delegate = self
            destination.preSelectedDate = self.selectedDate
        }
    }
    //关于popover的适配
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //选择的日期
    var selectedDate:Date = Date(){
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyy-MM-dd HH:mm"
            let stringTime = dateFormatter.string(from: self.selectedDate)
            //如果是今天的话就显示“今天”
            let dateToSearchString = self.dateFormatterDateVer.string(from: self.selectedDate)
            let todayDateString = self.dateFormatterDateVer.string(from: Date())
            if dateToSearchString == todayDateString{
                self.datePickerOutlet.setTitle("现在", for: .normal)
            }else{
                self.datePickerOutlet.setTitle(stringTime, for: .normal)
            }
            
        }
    }
    
//    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        if let datePickerVC = popoverPresentationController.presentedViewController as? DatePickerVC{
//            self.selectedDate = datePickerVC.datePickerOutlet.date
//        }
//    }
    
    
    

}
