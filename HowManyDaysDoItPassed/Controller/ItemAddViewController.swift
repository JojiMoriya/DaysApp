//
//  ItemAddViewController.swift
//  あれから何日？
//
//  Created by 守屋譲司 on 2020/11/01.
//

import UIKit
import RealmSwift

class ItemAddViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var itemMemoTextView: UITextView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    var itemTitle = ""
    var launchDate = Date()
    var limitDate = Date()
    var itemMemo = ""
    
    private var nowDateandTime:String!
    private var AselectedDate:Date!
    private var BselectedDate:Date!
    
    private var APicker: UIDatePicker!
    private var ATextField = UITextField()
    
    private var BPicker: UIDatePicker!
    private var BTextField = UITextField()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        itemMemoTextView.layer.borderColor = UIColor.black.cgColor
//        itemMemoTextView.layer.borderWidth = 2.0
        itemMemoTextView.layer.cornerRadius = 20
//        itemMemoTextView.layer.masksToBounds = true
        itemMemoTextView.backgroundColor = UIColor.systemGray6
        
        makeNowDate()
        makePickerBaseView(true)
        makePickerBaseView(false)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        itemTitle = itemTitleTextField.text ?? ""
        itemMemo = itemMemoTextView.text
        
        let checkBox = CheckBox()
        if checkBox.isChecked == true {
            launchDate = AselectedDate
            limitDate = BselectedDate
        } else {
            launchDate = AselectedDate
            limitDate = BselectedDate
        }
        print(limitDate)
    }
    
    func makeNowDate(){
        //現在のデバイス時間をsystemTimeで出力
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy年M月d日"
        nowDateandTime = formatter.string(from: now as Date)
        
        //内部変数の更新
        AselectedDate = now as Date?
        BselectedDate = now as Date?
    }
    
    func makePickerBaseView(_ isA:Bool) {
        var myTextField = UITextField()
        myTextField = makeTextField(isA)
        myTextField.text = isA ? "\(nowDateandTime!)" : "----年--月--日"
        
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
        myPicker.tag = isA ? 0 : 1
        myPicker.datePickerMode = .date
        myPicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        myPicker.preferredDatePickerStyle = .wheels
        
        //デリゲートの代わり
        myPicker.addTarget(self, action:  #selector(onDidChangeDate(sender:)), for: .valueChanged)
        
        return myPicker
    }
    
    //入力領域を引っ込める
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ATextField.endEditing(true)
        BTextField.endEditing(true)
    }
    
    //pickerが選択時デリゲートメソッド
    @objc internal func onDidChangeDate(sender: UIDatePicker){
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        
        //テキストフィールドと内部変数の更新
        let mySelectedDate: NSString = formatter.string(from: sender.date) as NSString
        if sender.tag == 0 {
            ATextField.text = mySelectedDate as String
            AselectedDate = sender.date
        }
        else {
            BTextField.text = mySelectedDate as String
            BselectedDate = sender.date
        }
        
        //ピッカー制約の更新
        if sender.tag == 0 {
            BPicker.minimumDate = AselectedDate
            
            if AselectedDate > BselectedDate {
                BTextField.text = (formatter.string(from: AselectedDate) as NSString) as String
            }
        }
        
    }
    
    
    
}
