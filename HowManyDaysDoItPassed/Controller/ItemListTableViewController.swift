//
//  ItemListTableViewController.swift
//  あれから何日？
//
//  Created by 守屋譲司 on 2020/11/01.
//

import UIKit
import RealmSwift

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
    }
    
    //Realmデータの全情報を取得する
    private func setRealm() {
        itemList = realm.objects(ItemData.self)
    }
    
    private func addRealm(itemTitle: String, launchDate: Date, limitDate: Date, itemMemo: String) {
        let addItem = ItemData()
        addItem.itemTitle = itemTitle
        addItem.launchDate = launchDate
        addItem.limitDate = limitDate
        addItem.itemMemo = itemMemo
        try! realm.write() {
            realm.add(addItem)
        }
    }
    
    @IBAction func addSegue(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "addItemToItemListVC" else { return }
        let addItemVC = unwindSegue.source as! ItemAddViewController
        addRealm(itemTitle: addItemVC.itemTitle, launchDate: addItemVC.launchDate, limitDate: addItemVC.limitDate, itemMemo: addItemVC.itemMemo)
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
            let itemContentVC =  segue.destination as! itemContentViewController
            itemContentVC.contentItemIndexPath = sender as! Int
        }
    }
    
    
}
