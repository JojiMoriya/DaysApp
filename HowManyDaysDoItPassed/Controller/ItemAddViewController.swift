//
//  ItemAddViewController.swift
//  あれから何日？
//
//  Created by 守屋譲司 on 2020/11/01.
//

import UIKit
import RealmSwift

class ItemAddViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemMemoTextView: UITextView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationDayTextFiled: UITextField!
    
    var itemTitle = ""
    var launchDate = Date()
    var limitDate = Date()
    var itemMemo = ""
    
    private var nowDate:String!
    private var AselectedDate:Date!
    private var BselectedDate:Date!
    
    private var APicker: UIDatePicker!
    private var ATextField = UITextField()
    
    private var BPicker: UIDatePicker!
    private var BTextField = UITextField()
    
    var pickerView: UIPickerView = UIPickerView()
    let list = ["1", "2", "3", "4", "5", "6", "7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemMemoTextView.layer.cornerRadius = 20
        itemMemoTextView.backgroundColor = UIColor.systemGray6
        
        makeNowDate()
        makePickerBaseView(true)
        makePickerBaseView(false)
         
        isChecked = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
        notificationDayTextFiled.inputView = pickerView
        notificationSwitch.isOn = false
        notificationDayTextFiled.text = list[0]
    }
    
//MARK: - CheckBoxの実装
    let checkedImage = UIImage(named: "checkOn")! as UIImage
    let uncheckedImage = UIImage(named: "checkOff")! as UIImage
    
    var isChecked: Bool = true {
        didSet{
            if isChecked == true {
                checkBoxButton.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                checkBoxButton.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
 
    @IBAction func checkBoxButtonClicked(_ sender: UIButton) {
        isChecked = !isChecked
    }
    
    //MARK: - DatePickerの実装
    func makeNowDate(){
        //現在のデバイス時間をsystemTimeで出力
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy年M月d日"
        nowDate = formatter.string(from: now as Date)
        
        //内部変数の更新
        AselectedDate = now as Date?
        BselectedDate = now as Date?
    }
    
    func makePickerBaseView(_ isA:Bool) {
        var myTextField = UITextField()
        myTextField = makeTextField(isA)
        myTextField.text = isA ? "\(nowDate!)" : "----年--月--日"
        
        if isA {
            ATextField = myTextField
            firstView.addSubview(ATextField)
        } else {
            BTextField = myTextField
            secondView.addSubview(BTextField)
        }
    }
    
    func makeTextField(_ isA:Bool) -> UITextField {
        let myTextField:UITextField!
        myTextField = UITextField(frame: CGRect(x: 2, y: 2, width:230, height: 56))
        
        myTextField.delegate = self
        myTextField.layer.cornerRadius = 20
        myTextField.layer.borderWidth = 1.5
        myTextField.layer.borderColor = UIColor.white.cgColor
        myTextField.font = UIFont.systemFont(ofSize: CGFloat(20))
        myTextField.textColor = UIColor.black
        myTextField.backgroundColor = UIColor.systemGray6
        myTextField.tintColor = UIColor.clear //キャレット(カーソル)を消す。
        //ここでピッカービューをセットする。
        if isA {
            APicker = makePicker(isA)
            myTextField.inputView = APicker
        } else {
            BPicker = makePicker(isA)
            myTextField.inputView = BPicker
        }
        myTextField.textAlignment = .center
        
        return myTextField
    }
    
    func makePicker(_ isA:Bool) -> UIDatePicker {
        let myPicker:UIDatePicker!
        myPicker = UIDatePicker()
        myPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200.0)
        myPicker.tag = isA ? 1 : 2
        myPicker.datePickerMode = .date
        myPicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        myPicker.preferredDatePickerStyle = .wheels
        
        //デリゲートの代わり
        myPicker.addTarget(self, action:  #selector(onDidChangeDate(sender:)), for: .valueChanged)
        
        return myPicker
    }
    
    //入力領域を引っ込める
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        itemTitleTextField.endEditing(true)
        ATextField.endEditing(true)
        BTextField.endEditing(true)
        itemMemoTextView.endEditing(true)
        notificationDayTextFiled.endEditing(true)
    }
    
    //pickerが選択時デリゲートメソッド
    @objc internal func onDidChangeDate(sender: UIDatePicker){
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        
        //テキストフィールドと内部変数の更新
        let mySelectedDate: NSString = formatter.string(from: sender.date) as NSString
        if sender.tag == 1 {
            ATextField.text = mySelectedDate as String
            AselectedDate = sender.date
        } else {
            BTextField.text = mySelectedDate as String
            BselectedDate = sender.date
        }
        
        //ピッカー制約の更新
        if sender.tag == 1 {
            BPicker.minimumDate = AselectedDate
            
            if AselectedDate > BselectedDate {
                BTextField.text = (formatter.string(from: AselectedDate) as NSString) as String
            }
        }
        
    }

    
    func setNotification() {
        let untilDay = notificationDayTextFiled.text
        let day = Int(untilDay!)! * -1
        let limitday = BPicker.date
        let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
        print(notificationDay)
        if notificationDay <= Date() {
            
        }
        var dateComponents = Calendar.current.dateComponents([.calendar, .year, .month, .day], from: notificationDay)
        dateComponents.hour = 18
        dateComponents.minute = 42
        print(dateComponents)
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "もうすぐ期限日です"
        content.body = "「\(itemTitle)」の期限日まであと\(untilDay!)日です"
        // ローカル通知リクエストを作成
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        // ユニークなIDを作る
        let identifier = NSUUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // ローカル通知リクエストを登録
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        itemTitle = itemTitleTextField.text ?? ""
        itemMemo = itemMemoTextView.text
        launchDate = AselectedDate
        
        if isChecked == true {
            limitDate = BselectedDate
        } else {
            limitDate = AselectedDate
        }
        
        if notificationSwitch.isOn == true {
            setNotification()
        }
        
    }
    
    @IBAction func test(_ sender: UIButton) {
        print("<Pending request identifiers>")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("identifier:\(request.identifier)")
                print("  title:\(request.content.title)")
                
                if request.trigger is UNCalendarNotificationTrigger {
                    let trigger = request.trigger as! UNCalendarNotificationTrigger
                    print("  <CalendarNotification>")
                    let components = DateComponents(calendar: Calendar.current, year: trigger.dateComponents.year, month: trigger.dateComponents.month, day: trigger.dateComponents.day, hour: trigger.dateComponents.hour, minute: trigger.dateComponents.minute)
                    print("    Scheduled Date:\(dateFormatter.string(from: components.date!))")
                    print("    Reperts:\(trigger.repeats)")
                    
                } else if request.trigger is UNTimeIntervalNotificationTrigger {
                    let trigger = request.trigger as! UNTimeIntervalNotificationTrigger
                    print("  <TimeIntervalNotification>")
                    print("    TimeInterval:\(trigger.timeInterval)")
                    print("    Reperts:\(trigger.repeats)")
                }
                print("----------------")
            }
        }
    }
}

extension ItemAddViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        self.notificationDayTextFiled.text = list[row]
    }
    
    
}
