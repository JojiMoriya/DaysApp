//
//  ItemTableViewCell.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/02.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet private weak var itemTitleLabel: UILabel!
    @IBOutlet private weak var passedDays: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
