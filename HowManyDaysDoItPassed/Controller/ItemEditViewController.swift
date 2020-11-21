//
//  ItemEditViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/11.
//

import UIKit
import RealmSwift

class ItemEditViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var editItemTitleTextFiled: UITextField!
    @IBOutlet weak var editItemLaunchDateTextFiled: UITextField!
    @IBOutlet weak var editItemLimitDateTextField: UITextField!
    @IBOutlet weak var editItemTextView: UITextView!
    @IBOutlet weak var limitDateSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationDateTextFiled: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var APicker: UIDatePicker!
    var BPicker: UIDatePicker!
    var AselectedDate: Date!
    var BselectedDate: Date!
    
    var editedItemTitle = ""
    var editedLaunchDate = Date()
    var editedLimitDate = Date()
    var editedItemMemo = ""
    
    var notificationID = ""
    var notificationDate = ""
    
    var pickerView: UIPickerView = UIPickerView()
    let list = ["1", "2", "3", "4", "5", "6", "7"]
    
    private let realm = try! Realm()
    private var itemList: Results<ItemData>!
    
    var editItemIndexPath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRealm()
        
        makeLaunchDatePicker()
        makeLimitDatePicker()
        
        editItemTextView.layer.cornerRadius = 20
        editItemTextView.backgroundColor = UIColor.systemGray6
        
        editItemTitleTextFiled.text = itemList[editItemIndexPath].itemTitle
        editItemLaunchDateTextFiled.text = dateFormat(date: itemList[editItemIndexPath].launchDate)
        AselectedDate = itemList[editItemIndexPath].launchDate
        editItemLimitDateTextField.text = setLimitDate()
        BselectedDate = itemList[editItemIndexPath].limitDate
        editItemTextView.text = itemList[editItemIndexPath].itemMemo
        
        pickerView.delegate = self
        pickerView.dataSource = self
        notificationDateTextFiled.inputView = pickerView

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
        editItemTitleTextFiled.endEditing(true)
        editItemLaunchDateTextFiled.endEditing(true)
        editItemLimitDateTextField.endEditing(true)
        editItemTextView.endEditing(true)
        notificationDateTextFiled.endEditing(true)
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
            print(AselectedDate!)
        } else {
            editItemLimitDateTextField.text = mySelectedDate as String
            BselectedDate = sender.date
            print(BselectedDate!)
        }
        
        //ピッカー制約の更新
        if sender.tag == 1 {
            BPicker.minimumDate = AselectedDate
        }
    }
    
    func setLimitDate() -> String{
        if itemList[editItemIndexPath].launchDate == itemList[editItemIndexPath].limitDate {
            limitDateSwitch.isOn = false
            return ""
        } else {
            limitDateSwitch.isOn = true 
            return dateFormat(date: itemList[editItemIndexPath].limitDate)
        }
    }
    
    func setNotification() {
        let notificationTitle = editItemTitleTextFiled.text
        let untilDay = notificationDateTextFiled.text
        let day = Int(untilDay!)! * -1
        let limitday = BPicker.date
        let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
        
        var dateComponents = Calendar.current.dateComponents([.calendar, .year, .month, .day], from: notificationDay)
        dateComponents.hour = 12
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "もうすぐ期限日です"
        content.body = "「\(notificationTitle!)」の期限日まであと\(untilDay!)日です"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = NSUUID().uuidString
        notificationID = identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func dateFormat(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        editedItemTitle = editItemTitleTextFiled.text ?? ""
        editedLaunchDate = AselectedDate
        if limitDateSwitch.isOn == true {
            editedLimitDate = BselectedDate
        } else {
            editedLimitDate = AselectedDate
        }
        editedItemMemo = editItemTextView.text
        
        if itemList[editItemIndexPath].notificationID != "" {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [itemList[editItemIndexPath].notificationID])
        }
        
        if notificationSwitch.isOn == true {
            notificationDate = notificationDateTextFiled.text ?? ""
            setNotification()
        }
        
        performSegue(withIdentifier: "unwindFromEditVC", sender: nil)
    }
    
    func alert (title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension ItemEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.notificationDateTextFiled.text = list[row]
        let untilDay = notificationDateTextFiled.text
        let day = Int(untilDay!)! * -1
        let limitday = BPicker.date
        let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
        if notificationDay <= Date() {
            alert(title: "注意", message: "通知日は明日以降になるよう設定してください。")
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    
}
