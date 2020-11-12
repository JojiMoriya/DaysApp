//
//  ItemEditViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/11.
//

import UIKit
import RealmSwift

class ItemEditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var editItemTitleTextFiled: UITextField!
    @IBOutlet weak var editItemLaunchDateTextFiled: UITextField!
    @IBOutlet weak var editItemLimitDateTextField: UITextField!
    var APicker: UIDatePicker!
    var BPicker: UIDatePicker!
    var AselectedDate: Date!
    var BselectedDate: Date!
    
    private let realm = try! Realm()
    private var itemList: Results<ItemData>!
    
    var editItemIndexPath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRealm()
        
        makeLaunchDatePicker()
        makeLimitDatePicker()
        
        editItemTitleTextFiled.text = itemList[editItemIndexPath].itemTitle
        editItemLaunchDateTextFiled.text = dateFormat(date: itemList[editItemIndexPath].launchDate)
        editItemLimitDateTextField.text = setLimitDate()

    }
    
    private func setRealm() {
        itemList = realm.objects(ItemData.self)
    }
    
    func makeLaunchDatePicker() {
        let launchDatePicker = UIDatePicker()
        APicker = launchDatePicker
        launchDatePicker.datePickerMode = .date
        launchDatePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        launchDatePicker.preferredDatePickerStyle = .wheels
        launchDatePicker.tag = 1
        editItemLaunchDateTextFiled.inputView = launchDatePicker
        launchDatePicker.addTarget(self, action:  #selector(onDidChangeDate(sender:)), for: .valueChanged)
    }
    
    func makeLimitDatePicker() {
        let limitDatePicker = UIDatePicker()
        BPicker = limitDatePicker
        limitDatePicker.datePickerMode = .date
        limitDatePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        limitDatePicker.preferredDatePickerStyle = .wheels
        limitDatePicker.tag = 2
        editItemLimitDateTextField.inputView = limitDatePicker
        limitDatePicker.addTarget(self, action:  #selector(onDidChangeDate(sender:)), for: .valueChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        editItemLaunchDateTextFiled.endEditing(true)
        editItemLimitDateTextField.endEditing(true)
    }
    
    //pickerが選択時デリゲートメソッド
    @objc internal func onDidChangeDate(sender: UIDatePicker){
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        
        //テキストフィールドと内部変数の更新
        let mySelectedDate: String = formatter.string(from: sender.date) as String
        if sender.tag == 1 {
            editItemLaunchDateTextFiled.text = mySelectedDate as String
            AselectedDate = sender.date
        } else {
            editItemLimitDateTextField.text = mySelectedDate as String
            BselectedDate = sender.date
        }
        
        //ピッカー制約の更新
        if sender.tag == 1 {
            BPicker.minimumDate = AselectedDate
        }
    }
    
    func setLimitDate() -> String{
        if itemList[editItemIndexPath].launchDate == itemList[editItemIndexPath].limitDate {
            return ""
        } else {
            return dateFormat(date: itemList[editItemIndexPath].limitDate)
        }
    }
    
    func dateFormat(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
