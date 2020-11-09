//
//  itemContentViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/03.
//

import UIKit
import RealmSwift

class itemContentViewController: UIViewController {

    @IBOutlet weak var contentTitleTextField: UITextField!
    @IBOutlet weak var contentPassedDaysLabel: UILabel!
    @IBOutlet weak var contentMemoTextView: UITextView!
    @IBOutlet weak var contentLaunchDateLabel: UILabel!
    
    private let realm = try! Realm()
    private var itemList: Results<ItemData>!
    
    var contentItemIndexPath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRealm()
        
        contentMemoTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentMemoTextView.layer.borderWidth = 2.0
        contentMemoTextView.layer.cornerRadius = 5.0
        contentMemoTextView.layer.masksToBounds = true
        
        contentTitleTextField.text = itemList[contentItemIndexPath].itemTitle
        contentPassedDaysLabel.text = calcInterval(date: itemList[contentItemIndexPath].launchDate)
        contentMemoTextView.text = itemList[contentItemIndexPath].itemMemo
        contentLaunchDateLabel.text = dateFormat(date: itemList[contentItemIndexPath].launchDate)
    }
    
    private func setRealm() {
        itemList = realm.objects(ItemData.self)
    }
    
    // 経過した日にちをStringで返すメソッド
    func calcInterval(date:Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let time = Int(interval)
        let day = time / 86400
        let dayInterval = String(format: "%d日", day)
        return dayInterval
    }
    
    func dateFormat(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
