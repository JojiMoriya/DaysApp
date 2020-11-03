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
        setRealm()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
    }
    
    //Realmデータの全情報を取得する
    private func setRealm() {
        itemList = realm.objects(ItemData.self)
    }
    
    private func addRealm(itemTitle: String, launchDate: Date, itemMemo: String) {
        let addItem = ItemData()
        addItem.itemTitle = itemTitle
        addItem.launchDate = launchDate
        addItem.itemMemo = itemMemo
        try! realm.write() {
            realm.add(addItem)
        }
    }
    
    @IBAction func addSegue(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "addItemToItemListVC" else { return }
        let addItemVC = unwindSegue.source as! ItemAddViewController
        addRealm(itemTitle: addItemVC.itemTitle, launchDate: addItemVC.launchDate, itemMemo: addItemVC.itemMemo)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPathRow = indexPath.row//閲覧するCellのindexPathを取得
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toItemContentVC", sender: selectedIndexPathRow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemContentVC" {
            let itemContentVC =  segue.destination as! itemContentViewController
            itemContentVC.contentItemIndexPath = sender as! Int
        }
    }

}
