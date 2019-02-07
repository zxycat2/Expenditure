//
//  AddingVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/22.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit
import CoreData



class AddingVC: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    //collectionView stuff
    //Colletion View Mole
    
    @IBOutlet weak var myCollectionView: UICollectionView!{
        didSet{
            self.myCollectionView.dataSource = self
            self.myCollectionView.delegate = self
        }
    }
    var myCollectionViewModel = ["coffee", "electronic", "game", "hotel", "restaurant", "shopping", "sim", "traffic", "travel"]
    //Number of cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.myCollectionViewModel.count
    }
    //Configure each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = self.myCollectionView.dequeueReusableCell(withReuseIdentifier: "myRegularCell", for: indexPath) as! MyCustomCollectionViewCell
        myCell.nameLabel.text = self.myCollectionViewModel[indexPath.item]
        //根据是否选中决定颜色
        if indexPath == self.selectedCellsIndexPath{
            myCell.imageView.image = UIImage(named: "white_"+self.myCollectionViewModel[indexPath.item])
            myCell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            myCell.nameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }else{
            myCell.imageView.image = UIImage(named: self.myCollectionViewModel[indexPath.item])
            myCell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            myCell.nameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        //手势
        let tap = UITapGestureRecognizer(target: self, action:  #selector(chooseCategory))
        myCell.addGestureRecognizer(tap)
        return myCell
    }
    //单击后执行选择
    var selectedCellsIndexPath:IndexPath? = nil
    @objc func chooseCategory(sender: UITapGestureRecognizer){
        let cell = (sender.view as! MyCustomCollectionViewCell)
        self.category = cell.nameLabel.text!
        self.selectedCellsIndexPath = self.myCollectionView.indexPath(for: cell)
        self.myCollectionView.reloadData()
    }
    //cell大小(目前是1/5的边长)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenLength = self.view.frame.width
        return CGSize(width: screenLength/5, height: screenLength/5)
    }
    //var
    
    @IBOutlet weak var expenceNumberTextField: UITextField!
    
    @IBOutlet weak var datePickerOutlet: UIButton!
    
    @IBAction func datePickerButton(_ sender: UIButton) {
    }
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        self.allSortsOfUpdating()
        self.container?.viewContext.perform{
            let contex = self.container?.viewContext
            try?contex?.save()
        }
            
    }
    
    func allSortsOfUpdating(){
        self.updateExpenceAndDetail()
        self.updateDatebase()
        self.navigationController?.popToRootViewController(animated: true)
        self.container?.viewContext.perform{
            let contex = self.container?.viewContext
            try?contex?.save()
        }
    }
    
    var isModifyingExistingEntry = false
    var exisingEntry:ExEntry? = nil
    
    //单击函数
    @objc func singelTabpFunction(sender:UITapGestureRecognizer){
        self.textField.resignFirstResponder()
        self.expenceNumberTextField.resignFirstResponder()
    }
    var dateSelectedBuffer:Date? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化delegate
        if self.preSetSelectedDate != nil{
            self.selectedDate = preSetSelectedDate!
        }
        if self.dateSelectedBuffer != nil{
            self.selectedDate = self.dateSelectedBuffer!
        }
        self.updateDatePicker()
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
        //如果是在编辑已创建的entry的话
        if self.isModifyingExistingEntry{
            self.container?.viewContext.perform {
                let contex = self.container?.viewContext
                let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
                request.predicate = NSPredicate(format: "uuid = %@", self.uuid)
                let fetchedExistingEntry = try?contex?.fetch(request)
                if fetchedExistingEntry != nil{
                    self.exisingEntry = fetchedExistingEntry!![0]
                    //设置本地变量
                    self.selectedDate = (self.exisingEntry?.dateTime)!
                    self.category = (self.exisingEntry?.category)!
                    self.detail = (self.exisingEntry?.detail)!
                    self.textField.text = (self.exisingEntry?.detail)!
                    self.expenceNumber = (self.exisingEntry?.expence)!
                    self.expenceNumberTextField.text = String((self.exisingEntry?.expence)!)
                }
            }
        }
        
    }
    
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
            self.exisingEntry?.dateTime = self.selectedDate
            self.exisingEntry?.category = self.category
            self.exisingEntry?.detail = self.detail
            self.exisingEntry?.expence = self.expenceNumber
        }else{
            self.container?.performBackgroundTask{context in
                _ = ExEntry.updateDatabase(in: context, number: self.expenceNumber, category: self.category, detail: self.detail, dateTime: self.selectedDate, uuid:self.uuid)
                try? context.save()
            }
        }
    }
    //花费数字，备注，类别
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
    var preSetSelectedDate:Date? = nil
    //选择的日期
    var selectedDate:Date = Date(){
        didSet{
            self.updateDatePicker()
        }
    }
    //更新Datepicker
    func updateDatePicker(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm"
        let stringTime = dateFormatter.string(from: self.selectedDate)
        //如果是今天的话就显示“现在”
        let dateToSearchString = dateFormatter.string(from: self.selectedDate)
        let todayDateString = dateFormatter.string(from: Date())
        if dateToSearchString == todayDateString{
            self.datePickerOutlet.setTitle("现在", for: .normal)
        }else{
            self.datePickerOutlet.setTitle(stringTime, for: .normal)
        }
    }
    
//    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//        if let datePickerVC = popoverPresentationController.presentedViewController as? DatePickerVC{
//            self.selectedDate = datePickerVC.datePickerOutlet.date
//        }
//    }
    
    
    

}
