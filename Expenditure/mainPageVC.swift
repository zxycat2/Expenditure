//
//  mainPageVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/22.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit
import CoreData

class mainPageVC: UIViewController,NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    
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
        //测试用
        self.dateToSearch = Date()
        //
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    //fetchedResult 相关
    var dateToSearch:Date?{
        didSet{
            self.updateTable()
        }
    }
    var dateFormatterToSearch = DateFormatter(){
        didSet{
            self.dateFormatterToSearch.dateFormat = "yyy-MM-dd"
        }
    }
    var dateFormatterToDisplay = DateFormatter(){
        didSet{
            self.dateFormatterToDisplay.dateFormat = "yyy-MM-dd HH:mm"
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<ExEntry>?
    var container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    func updateTable() {
        if let context = self.container?.viewContext,self.dateToSearch != nil{
            print("did the query")
            let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
//            request.predicate = NSPredicate(format: "ANY expence < %f", Float(100))
            //测试
//            if let entryCount = try? context.count(for: ExEntry.fetchRequest()){
//                print(entryCount)
//            }
            //
            self.fetchedResultsController = NSFetchedResultsController<ExEntry>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            print(fetchedResultsController?.fetchedObjects?.count)
            fetchedResultsController?.delegate = self
            try?fetchedResultsController?.performFetch()
            self.myTableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "regularCell", for: indexPath)
        let myCell = cell as! MainPageTableViewCell
        if let entry = fetchedResultsController?.object(at: indexPath){
            myCell.detailStringLabel.text = entry.detail ?? "?"
            myCell.expenceNumberLabel.text = String(entry.expence) 
            myCell.categoryLabel.text = entry.category ?? "??"
        }
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
