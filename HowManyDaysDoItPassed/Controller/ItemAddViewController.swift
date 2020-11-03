//
//  ItemAddViewController.swift
//  あれから何日？
//
//  Created by 守屋譲司 on 2020/11/01.
//

import UIKit
import RealmSwift

class ItemAddViewController: UIViewController {
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemDatePicker: UIDatePicker!
    @IBOutlet weak var itemMemoTextView: UITextView!
    
    var itemTitle = ""
    var launchDate = Date()
    var itemMemo = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemMemoTextView.layer.borderColor = UIColor.black.cgColor
        itemMemoTextView.layer.borderWidth = 2.0
        itemMemoTextView.layer.cornerRadius = 10.0
        itemMemoTextView.layer.masksToBounds = true
        
        itemDatePicker.datePickerMode = .date
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        itemTitle = itemTitleTextField.text ?? ""
//        launchDate = format(date: itemDatePicker.date)
//        launchDate = calcInterval(date: itemDatePicker.date)
        launchDate = itemDatePicker.date
        itemMemo = itemMemoTextView.text
    }
    
    func format(date:Date)->String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let strDate = dateformatter.string(from: date)
        
        return strDate
    }
    
    func calcInterval(date:Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let time = Int(interval)
        let day = time / 86400
        let dayInterval = String(format: "%d日", day)
        return dayInterval
    }
    
    

}
