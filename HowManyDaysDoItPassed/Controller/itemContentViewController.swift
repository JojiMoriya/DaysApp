//
//  itemContentViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/03.
//

import UIKit
import RealmSwift

class itemContentViewController: UIViewController {
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var contentPassedDaysLabel: UILabel!
    @IBOutlet weak var contentMemoTextView: UITextView!
    
    private let realm = try! Realm()
    private var itemList: Results<ItemData>!
    
    var contentItemIndexPath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRealm()
        
        contentMemoTextView.layer.borderColor = UIColor.black.cgColor
        contentMemoTextView.layer.borderWidth = 2.0
        contentMemoTextView.layer.cornerRadius = 10.0
        contentMemoTextView.layer.masksToBounds = true
        
        contentTitleLabel.text = itemList[contentItemIndexPath].itemTitle
        contentPassedDaysLabel.text = calcInterval(date: itemList[contentItemIndexPath].launchDate)
        contentMemoTextView.text = itemList[contentItemIndexPath].itemMemo

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
