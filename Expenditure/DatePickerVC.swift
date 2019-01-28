//
//  DatePickerVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/24.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
    
    let marginSize = CGFloat(bitPattern: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if let contentSize = self.stackView?.sizeThatFits(UIView.layoutFittingCompressedSize){
            preferredContentSize = CGSize(width: contentSize.width+self.marginSize, height: contentSize.height+self.marginSize)
        }
    }
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    @IBAction func datePicker(_ sender: Any) {
        
    }
    @IBOutlet var topleverlView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBAction func confirmButton(_ sender: Any) {
        if let addingVC = popoverPresentationController?.delegate as? AddingVC{
            addingVC.selectedDate = self.datePickerOutlet.date
        }
        if let mainVC = popoverPresentationController?.delegate as? mainPageVC{
            mainVC.dateToSearch = self.datePickerOutlet.date
        }
        self.dismiss(animated: true, completion: nil)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        print("stuff")
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
