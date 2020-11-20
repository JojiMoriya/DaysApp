//
//  ItemData.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/01.
//

import RealmSwift

class ItemData: Object {
    @objc dynamic var itemTitle = ""
    @objc dynamic var launchDate = Date()
    @objc dynamic var limitDate = Date()
    @objc dynamic var itemMemo = ""
    @objc dynamic var notificationID = ""
    @objc dynamic var notificationDate = ""
}
