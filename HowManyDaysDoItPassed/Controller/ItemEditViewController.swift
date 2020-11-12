//
//  ItemEditViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/11.
//

import UIKit
import RealmSwift

class ItemEditViewController: UIViewController {

    @IBOutlet weak var editItemTitleTextFiled: UITextField!
    @IBOutlet weak var editItemLaunchDateTextFiled: UITextField!
    @IBOutlet weak var editItemLimitDateTextField: UITextField!
    
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
        launchDatePicker.datePickerMode = .date
        launchDatePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        launchDatePicker.preferredDatePickerStyle = .wheels
        editItemLaunchDateTextFiled.inputView = launchDatePicker
    }
    
    func makeLimitDatePicker() {
        let limitDatePicker = UIDatePicker()
        limitDatePicker.datePickerMode = .date
        limitDatePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        limitDatePicker.preferredDatePickerStyle = .wheels
        editItemLimitDateTextField.inputView = limitDatePicker
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
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
