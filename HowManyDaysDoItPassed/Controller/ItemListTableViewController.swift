//
//  ItemListTableViewController.swift
//  あれから何日？
//
//  Created by 守屋譲司 on 2020/11/01.
//

import UIKit
import RealmSwift
import NotificationCenter

class ItemListTableViewController: UITableViewController {
    @IBOutlet private var itemListTableView: UITableView!
    
    private let realm = try! Realm()
    private var itemList: Results<ItemData>!
    private var selectedIndexPathRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemListTableView.rowHeight = 70
        setRealm()
        
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.title = "編集"
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        buttonPendingListTouchUpInside()
    }
    
    //実行待ち通知を一覧するメソッド
    func buttonPendingListTouchUpInside() {
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
    
    //Realmデータの全情報を取得する
    private func setRealm() {
        itemList = realm.objects(ItemData.self)
    }
    
    private func addRealm(itemTitle: String, launchDate: Date, limitDate: Date, itemMemo: String, notificationID: String, notificationDate: String) {
        let addItem = ItemData()
        addItem.itemTitle = itemTitle
        addItem.launchDate = launchDate
        addItem.limitDate = limitDate
        addItem.itemMemo = itemMemo
        addItem.notificationID = notificationID
        addItem.notificationDate = notificationDate
        try! realm.write() {
            realm.add(addItem)
        }
    }
    
    @IBAction func addSegue(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "addItemToItemListVC" else { return }
        let addItemVC = unwindSegue.source as! ItemAddViewController
        addRealm(itemTitle: addItemVC.itemTitle, launchDate: addItemVC.launchDate, limitDate: addItemVC.limitDate, itemMemo: addItemVC.itemMemo, notificationID: addItemVC.notificationID, notificationDate: addItemVC.notificationDate)
        itemListTableView.reloadData()
    }
    
    // 経過した日にちをStringで返すメソッド
    func calcInterval(date:Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let time = Int(interval)
        let day = time / 86400
        let dayInterval = String(format: "%d日", day)
        return dayInterval
    }
    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        let item = itemList[indexPath.row]
        cell.itemTitleLabel.text = item.itemTitle
        cell.passedDays.text = calcInterval(date: item.launchDate)
        return cell
    }
    
    //編集ボタンがタップされた呼ばれる
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        itemListTableView.setEditing(editing, animated: animated)
    }
    
    //セルが編集されたら呼ばれる
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alert: UIAlertController = UIAlertController(title: "注意", message: "削除してよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
        let destructiveAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            let deleteItem = self.itemList[indexPath.row]
            //Realmデータをもとに削除するアイテムの通知を削除
            if deleteItem.notificationID != "" {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [deleteItem.notificationID])
            }
            try! self.realm.write {
                self.realm.delete(deleteItem)
            }
            self.itemListTableView.deleteRows(at: [indexPath], with: .fade)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:{  // styleはあえてdefaultにした、ボタンの順番の都合上
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            return
        })
        
        alert.addAction(destructiveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPathRow = indexPath.row//閲覧するCellのindexPathを取得
        performSegue(withIdentifier: "toItemContentVC", sender: selectedIndexPathRow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemContentVC" {
            let itemContentVC =  segue.destination as! ItemContentViewController
            itemContentVC.contentItemIndexPath = sender as! Int
        }
    }
    
    
}
