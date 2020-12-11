//
//  MyScrollView.swift
//  HowManyDaysDoItPassed
//
//  Created by 守屋譲司 on 2020/12/11.
//

import UIKit

class MyScrollView: UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.touchesBegan(touches, with: event)
    }

}
