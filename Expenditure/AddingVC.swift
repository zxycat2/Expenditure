//
//  AddingVC.swift
//  Expenditure
//
//  Created by 周熙岩 on 2019/1/22.
//  Copyright © 2019 DoDo. All rights reserved.
//

import UIKit



class AddingVC: UIViewController, UITextFieldDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置监视键盘位置
        NotificationCenter.default.addObserver(self,selector:#selector(self.keyboardPositionDidChange(_:)),name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        
        
        // Do any additional setup after loading the view.
    }
    

    //在监视到键盘变化后call的函数，把textView上移
    @objc func keyboardPositionDidChange(_ notification:Notification){
        let info  = notification.userInfo
        let keyboardRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let offSetY = keyboardRect.origin.y - UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.3, animations: {
            self.textField.transform = CGAffineTransform(translationX: 0, y: offSetY)
            }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return true
    }
    
   
    
    @IBOutlet weak var textField: UITextField!
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
