//
//  ItemEditViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/11.
//

import UIKit

class ItemEditViewController: UIViewController {

    @IBOutlet weak var editItemTitleTextFiled: UITextField!
    @IBOutlet weak var editItemLaunchDateTextFiled: UITextField!
    @IBOutlet weak var editItemLimitDateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeLaunchDatePicker()
        makeLimitDatePicker()

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
}
