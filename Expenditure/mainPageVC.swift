//
//  mainPageVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/22.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit
import CoreData

class mainPageVC: UIViewController,NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func datePickerButton(_ sender: UIButton) {
    }
    @IBOutlet weak var datePickerOutlet: UIButton!
    //准备datePicker popover的segue(只显示日期不显示时间)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popSegue"{
            if let destination = segue.destination as? DatePickerVC{
                let myPopoverPresentaionController = destination.popoverPresentationController
                myPopoverPresentaionController?.delegate = self
                destination.myDatePickerMode = "Just Date"
                destination.preSelectedDate = self.dateToSearch
            }
        }
        if segue.identifier == "modifyExistingEntry"{
            if let cell = ((sender as? UIGestureRecognizer)?.view as? MainPageTableViewCell){
                print("Did prepare!!!!!!!!!!!!!!!")
                let destinationAddingPage = segue.destination as! AddingVC
                destinationAddingPage.isModifyingExistingEntry = true
                destinationAddingPage.uuid = cell.uuid!
                print(destinationAddingPage.uuid)
            }
        }
        
    }
    //关于popover的适配
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //table滑动删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let cellToBeDeletedsUUID = (tableView.cellForRow(at: indexPath) as! MainPageTableViewCell).uuid
            //更新数据库
            self.container?.viewContext.perform {
                let contex = self.container?.viewContext
                let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
                request.predicate = NSPredicate(format: "uuid = %@", cellToBeDeletedsUUID!)
                let cellToBeDeleted = try?contex?.fetch(request)
                if cellToBeDeleted != nil{
                    contex!.delete((cellToBeDeleted!![0]) as NSManagedObject)
                    print("deleted")
                self.updateTable()
                }
            
            }
        
        }
    }
    //table反向滑
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "滑反了，傻逼", handler: {_,_,_ in
            //反着滑动执行的操作，目前还没有
        })])
    }
    
    
    //NSFetchedResultsControllerDelegate相关
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.myTableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: self.myTableView.insertSections([sectionIndex], with: .fade)
        case .delete: self.myTableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateTable()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.myTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.myTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.myTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.myTableView.deleteRows(at: [indexPath!], with: .fade)
            self.myTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.myTableView.endUpdates()
    }
    
    

    override func viewDidLoad() {
        //
        super.viewDidLoad()
        //初始化
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.dateFormatterDateVer.dateFormat = "yyy-MM-dd"
        self.dateFormatterDateTimeVer.dateFormat = "yyy-MM-dd HH:mm"
        self.dateFormatterTimeVer.dateFormat = "HH:mm"
        self.dateToSearch = Date()
        // Do any additional setup after loading the view.
    }
    let dateFormatterDateVer = DateFormatter()
    let dateFormatterDateTimeVer = DateFormatter()
    let dateFormatterTimeVer = DateFormatter()
    //fetchedResult 相关
    //当前要搜索的日期相关
    func getUpperOrLowerDate(timeString:String) -> Date {
        let dateString = self.dateFormatterDateVer.string(from: self.dateToSearch!)
        let dateTimeString = dateString + timeString
        let dateTime = self.dateFormatterDateTimeVer.date(from: dateTimeString)
        return dateTime!
    }
    var dateToSearchUpper:Date{
        return self.getUpperOrLowerDate(timeString: " 23:59")
    }
    var dateToSearchLower:Date{
        return self.getUpperOrLowerDate(timeString: " 00:00")
    }
    //已选定日期
    var dateToSearch:Date?{
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyy-MM-dd"
            let stringTime = dateFormatter.string(from: self.dateToSearch!)
            //如果是今天的话就显示“今天”
            let dateToSearchString = self.dateFormatterDateVer.string(from: self.dateToSearch!)
            let todayDateString = self.dateFormatterDateVer.string(from: Date())
            if dateToSearchString == todayDateString{
                self.datePickerOutlet.setTitle("今天", for: .normal)
            }else{
                self.datePickerOutlet.setTitle(stringTime, for: .normal)
            }
            
            self.updateTable()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<ExEntry>?
    var container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    func updateTable() {
        print("Update table")
        if let context = self.container?.viewContext,self.dateToSearch != nil{
            print("did the query")
            let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
            request.predicate = NSPredicate(format: "dateTime BETWEEN { %@ , %@ }", self.dateToSearchLower as CVarArg, self.dateToSearchUpper as CVarArg)

            self.fetchedResultsController = NSFetchedResultsController<ExEntry>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try?fetchedResultsController?.performFetch()
            self.myTableView.reloadData()
        }
        
    }
    
    //segue到addingPage
    @objc func segueWayToAddingFromExistingEntry(sender:UITapGestureRecognizer){
        if let cell = (sender.view as? MainPageTableViewCell){
            let destinationAddingPage = AddingVC()
            destinationAddingPage.isModifyingExistingEntry = true
            destinationAddingPage.uuid = cell.uuid!
            performSegue(withIdentifier: "modifyExistingEntry", sender: sender)
        }
    }
    //准备每个tableView的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "regularCell", for: indexPath)
        let myCell = cell as! MainPageTableViewCell
        if let entry = fetchedResultsController?.object(at: indexPath){
            myCell.detailStringLabel.text = entry.detail ?? "?"
            myCell.expenceNumberLabel.text = String(entry.expence) 
            myCell.categoryLabel.text = entry.category ?? "??"
            myCell.uuid = entry.uuid
            //设置类别图标
            if let iconImage = UIImage(named: entry.category ?? "??"){
                myCell.iconImage.image = iconImage
            }else{
                myCell.iconImage.image = UIImage(named:"sadFace")
            }
            let timeString = self.dateFormatterTimeVer.string(from: entry.dateTime!)
            myCell.timeLabel.text = timeString
        }
        //单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(segueWayToAddingFromExistingEntry))
        singleTap.numberOfTapsRequired = 1
        myCell.addGestureRecognizer(singleTap)
        return myCell
    }
    
    @IBAction func addButton(_ sender: Any) {
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
