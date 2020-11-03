//
//  itemContentViewController.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/11/03.
//

import UIKit

class itemContentViewController: UIViewController {
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var contentPassedDaysLabel: UILabel!
    @IBOutlet weak var contentMemoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentMemoTextView.layer.borderColor = UIColor.black.cgColor
        contentMemoTextView.layer.borderWidth = 2.0
        contentMemoTextView.layer.cornerRadius = 10.0
        contentMemoTextView.layer.masksToBounds = true

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
