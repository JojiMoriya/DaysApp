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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRealm()
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))

    }
    
    private func setRealm() {
        itemList = realm.objects(ItemData.self)
    }
    
    func addRealm(itemTitle: String, launchDate: Date, itemMemo: String) {
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
        /// append
        addRealm(itemTitle: addItemVC.itemTitle, launchDate: addItemVC.launchDate, itemMemo: addItemVC.itemMemo)
        itemListTableView.reloadData()
    }
    
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
    

}
