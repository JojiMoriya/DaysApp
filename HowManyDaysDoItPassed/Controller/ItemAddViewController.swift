//
//  ItemAddViewController.swift
//  あれから何日？
//
//  Created by 守屋譲司 on 2020/11/01.
//

import UIKit
import RealmSwift

class ItemAddViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemMemoTextView: UITextView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var limitDateSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationDayTextFiled: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var scrollView: MyScrollView!
    
    var itemTitle = ""
    var launchDate = Date()
    var limitDate = Date()
    var itemMemo = ""
    var notificationID = ""
    var notificationDate = ""
    
    private var nowDate:String!
    private var AselectedDate:Date!
    private var BselectedDate:Date!
    private var APicker: UIDatePicker!
    private var ATextField = UITextField()
    private var BPicker: UIDatePicker!
    private var BTextField = UITextField()
    
    private var pickerView: UIPickerView = UIPickerView()
    private let list = ["1", "2", "3", "4", "5", "6", "7"]
    private var activeTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNowDate()
        makePickerBaseView(true)
        makePickerBaseView(false)
        setMinimumDate()
        setItemMemoTextView()
        setNotificationDatePicker()
        setAddButton()
        setSwitch()
        
        itemTitleTextField.delegate = self
        itemMemoTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - DatePickerの実装
    func makeNowDate(){
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: +1, to: Date())!
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy年M月d日"
        nowDate = formatter.string(from: today as Date)
        AselectedDate = today
        BselectedDate = tomorrow
    }
    
    func makePickerBaseView(_ isA:Bool) {
        var myTextField = UITextField()
        myTextField = makeTextField(isA)
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy年M月d日"
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
        myPicker.addTarget(self, action:  #selector(onDidChangeDate(sender:)), for: .valueChanged)
        
        return myPicker
    }
    
    @objc internal func onDidChangeDate(sender: UIDatePicker){
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        
        let mySelectedDate = formatter.string(from: sender.date)
        if sender.tag == 1 {
            ATextField.text = mySelectedDate
            AselectedDate = sender.date
        } else {
            BTextField.text = mySelectedDate
            BselectedDate = sender.date
        }
        
        if sender.tag == 1 {
            let minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: AselectedDate)!
            BPicker.minimumDate = minimumDate
            if AselectedDate > BselectedDate {
                BTextField.text = (formatter.string(from: minimumDate))
                BPicker.date = minimumDate
            }
            if notificationSwitch.isOn == true {
                let untilDay = notificationDayTextFiled.text
                let day = Int(untilDay!)! * -1
                let limitday = BselectedDate!
                let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
                if notificationDay <= AselectedDate {
                    alert(title: "注意", message: "通知日は明日以降になるよう設定してください。")
                    addButton.isEnabled = false
                    addButton.setTitleColor(UIColor.systemGray4, for: .normal)
                } else {
                    if itemTitleTextField.text != "" {
                        addButton.isEnabled = true
                        addButton.setTitleColor(UIColor.black, for: .normal)
                    }
                }
            }
        } else {
            if notificationSwitch.isOn == true {
                let untilDay = notificationDayTextFiled.text
                let day = Int(untilDay!)! * -1
                let limitday = BselectedDate!
                let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
                if notificationDay <= AselectedDate {
                    alert(title: "注意", message: "通知日は明日以降になるよう設定してください。")
                    addButton.isEnabled = false
                    addButton.setTitleColor(UIColor.systemGray4, for: .normal)
                } else {
                    if itemTitleTextField.text != "" {
                        addButton.isEnabled = true
                        addButton.setTitleColor(UIColor.black, for: .normal)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        itemTitleTextField.endEditing(true)
        ATextField.endEditing(true)
        BTextField.endEditing(true)
        itemMemoTextView.endEditing(true)
        notificationDayTextFiled.endEditing(true)
    }
    
    //MARK: - 各種部品の初期設定
    func setMinimumDate() {
        let minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        BPicker.minimumDate = minimumDate
    }
    func setItemMemoTextView() {
        itemMemoTextView.layer.borderColor = UIColor.systemGray4.cgColor
        itemMemoTextView.layer.borderWidth = 1
        itemMemoTextView.layer.cornerRadius = 20
        itemMemoTextView.backgroundColor = UIColor.systemGray6
    }
    
    func setNotificationDatePicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        notificationDayTextFiled.inputView = pickerView
        notificationDayTextFiled.text = list[0]
    }
    
    func setAddButton() {
        addButton.layer.cornerRadius = 20
        addButton.setTitleColor(UIColor.systemGray4, for: .normal)
        addButton.isEnabled = false
    }
    
    func setSwitch() {
        limitDateSwitch.isOn = false
        notificationSwitch.isOn = false
    }
    
    //MARK: - 通知の設定
    func setNotification() {
        let untilDay = notificationDayTextFiled.text
        let day = Int(untilDay!)! * -1
        let limitday = BPicker.date
        let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
        
        var dateComponents = Calendar.current.dateComponents([.calendar, .year, .month, .day], from: notificationDay)
        dateComponents.hour = 12
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "もうすぐ期限日です"
        content.body = "「\(itemTitle)」の期限日まであと\(untilDay!)日です"
        
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
    
    //MARK: - TitleTextFieldのデリゲートメソッド
    @IBAction func checkTitleIsNil(_ sender: UITextField) {
        if sender.text == "" {
            addButton.isEnabled = false
            addButton.setTitleColor(UIColor.systemGray4, for: .normal)
        } else {
            addButton.isEnabled = true
            addButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    //MARK: - notificationSwitchのデリゲートメソッド
    @IBAction func checkNotificationIsCollect(_ sender: UISwitch) {
        if notificationSwitch.isOn == true {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted{
                    UNUserNotificationCenter.current().delegate = self
                }
            }
            
            let untilDay = notificationDayTextFiled.text
            let day = Int(untilDay!)! * -1
            let limitday = BPicker.date
            let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
            if notificationDay <= Date() {
                addButton.isEnabled = false
                addButton.setTitleColor(UIColor.systemGray4, for: .normal)
            } else {
                if itemTitleTextField.text != "" {
                    addButton.isEnabled = true
                    addButton.setTitleColor(UIColor.black, for: .normal)
                }
            }
        } else {
            if itemTitleTextField.text != "" {
                addButton.isEnabled = true
                addButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
    
    //MARK: - TextViewのキーボード監視
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = itemMemoTextView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = itemMemoTextView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = UITextView()
    }
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        if activeTextView == itemMemoTextView {
            let userInfo = notification.userInfo!
            let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let myBoundSize: CGSize = UIScreen.main.bounds.size
            
            let textViewLimit = activeTextView.frame.origin.y + activeTextView.frame.height + 100.0
            let keyboardLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
            
            if textViewLimit >= keyboardLimit {
                scrollView.contentOffset.y = textViewLimit - keyboardLimit
            }
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        if activeTextView == itemMemoTextView {
            scrollView.contentOffset.y = 0
        }
    }
    
    //MARK: - 追加ボタンが押された際の処理
    @IBAction func addButtonPressed(_ sender: UIButton) {
        itemTitle = itemTitleTextField.text!
        itemMemo = itemMemoTextView.text
        launchDate = AselectedDate
        
        if limitDateSwitch.isOn == true {
            limitDate = BselectedDate
        } else {
            limitDate = AselectedDate //期限日が設定されない場合は、開始日を格納しておき、それを元に後々の処理を判別
        }
        
        if notificationSwitch.isOn == true && limitDateSwitch.isOn == true {
            notificationDate = notificationDayTextFiled.text ?? ""
            setNotification()
        }
    }
    
    func alert (title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        let untilDay = notificationDayTextFiled.text
        let day = Int(untilDay!)! * -1
        let limitday = BPicker.date
        let notificationDay = Calendar.current.date(byAdding: .day, value: day, to: limitday)!
        if notificationDay <= Date() {
            alert(title: "注意", message: "通知日は明日以降になるよう設定してください。")
            addButton.isEnabled = false
            addButton.setTitleColor(UIColor.systemGray4, for: .normal)
        } else {
            if itemTitleTextField.text != "" {
                addButton.isEnabled = true
                addButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
    
    
}
