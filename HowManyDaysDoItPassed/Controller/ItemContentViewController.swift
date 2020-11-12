//
//  itemContentViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/03.
//

import UIKit
import RealmSwift

class ItemContentViewController: UIViewController {

    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var contentPassedDaysLabel: UILabel!
    @IBOutlet weak var contentMemoTextView: UITextView!
    @IBOutlet weak var contentLaunchDateLabel: UILabel!
    @IBOutlet weak var limitDateLabel: UILabel!
    @IBOutlet weak var untilLimitDateLabel: UILabel!
    
    private let realm = try! Realm()
    private var itemList: Results<ItemData>!
    
    var contentItemIndexPath = 0
    var limitDateString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRealm()
        
        contentMemoTextView.layer.cornerRadius = 20
        contentMemoTextView.backgroundColor = UIColor.systemGray6
        
        contentTitleLabel.text = itemList[contentItemIndexPath].itemTitle
        contentPassedDaysLabel.text = calcInterval(date: itemList[contentItemIndexPath].launchDate)
        contentMemoTextView.text = itemList[contentItemIndexPath].itemMemo
        contentLaunchDateLabel.text = dateFormat(date: itemList[contentItemIndexPath].launchDate)
        setLimitLabel()
        limitDateLabel.text = limitDateString
        if itemList[contentItemIndexPath].limitDate != itemList[contentItemIndexPath].launchDate {
            untilLimitDateLabel.text = calcUntilDateInterval(date: itemList[contentItemIndexPath].limitDate)
        } else {
            untilLimitDateLabel.text = "期限なし"
        }
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
    
    func calcUntilDateInterval(date:Date) -> String {
        let date1 = Date()
        let date2 = itemList[contentItemIndexPath].limitDate
        let elapsedDays = Calendar.current.dateComponents([.day], from: date1, to: date2).day!
        let dayInterval = String(format: "あと%d日", elapsedDays )
        return dayInterval
    }
    
    func dateFormat(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func setLimitLabel() {
        if itemList[contentItemIndexPath].launchDate == itemList[contentItemIndexPath].limitDate {
            limitDateString = "期限なし"
        } else {
            limitDateString = dateFormat(date: itemList[contentItemIndexPath].limitDate)
        }
    }

    @IBAction func buttonPressedToEditVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToEditVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditVC" {
            let itemEditVC =  segue.destination as! ItemEditViewController
            itemEditVC.editItemIndexPath = contentItemIndexPath
        }
    }
    
    private func editRealm(itemTitle: String, launchDate: Date, limitDate: Date, itemMemo: String) {
        try! realm.write {
            itemList[contentItemIndexPath].itemTitle = itemTitle
            itemList[contentItemIndexPath].launchDate = launchDate
            itemList[contentItemIndexPath].limitDate = limitDate
            itemList[contentItemIndexPath].itemMemo = itemMemo
        }
    }
    
    @IBAction func unwindFromEditVC(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "unwindFromEditVC" else { return }
        let itemEditVC = unwindSegue.source as! ItemEditViewController
        editRealm(itemTitle: itemEditVC.editedItemTitle, launchDate: itemEditVC.editedLaunchDate, limitDate: itemEditVC.editedLimitDate, itemMemo: itemEditVC.editedItemMemo)
        self.viewDidLoad()
    }
}
