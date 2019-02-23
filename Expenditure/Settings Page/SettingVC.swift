//
//  SettingVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/2/23.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit
import CoreData

class SettingVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }
     var container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var documentInteractionController = UIDocumentInteractionController()
    //导出JSON，先query所有数据，然后搞成JSONData，存到CACHE里，再用别的应用打开/AirDrop
    @IBAction func exportJSON(_ sender: Any) {
        if let context = self.container?.viewContext{
            let request:NSFetchRequest<ExEntry> = ExEntry.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
            let result = try?context.fetch(request)
            if result?.count ?? 0 > 0{
                print(result?.count)
                //transform to JSON and write to local URL
                var myExEntryForJSONList:[ExEntryForJSON] = []
                for exentry in result!{
                    let entryForJson = ExEntryForJSON(year: exentry.year!, uuid: exentry.uuid!, month: exentry.month!, expence: exentry.expence, detail: exentry.detail!, day: exentry.day!, dateTime: exentry.dateTime!, category: exentry.category!)
                    myExEntryForJSONList.append(entryForJson)
                }
                let jsonEncoder = JSONEncoder()
                let jsonData = try? jsonEncoder.encode(myExEntryForJSONList)
                let myTempFileUrl = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("TempJSON.json")
                if myTempFileUrl != nil{
                    do{
                        print(myTempFileUrl!.path)
                        print(jsonData)
                        try jsonData!.write(to: myTempFileUrl!)
                        let retrieveData = try Data.init(contentsOf: myTempFileUrl!, options: .uncached)
                        print(retrieveData)
                        //
                        self.documentInteractionController.url = myTempFileUrl!
                       documentInteractionController.presentOpenInMenu(from: CGRect(x: 0, y: 0, width: 90, height: 90), in: self.view, animated: true)
                    }catch {
                        print("cant write the file")
                    }
                }
                
//                let json = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
                
            }else{
                print("No data")
            }
            
        }
        
    }
    

    @IBOutlet var myTableView: UITableView!
    

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
