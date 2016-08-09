//
//  MaterialBarButton.swift
//  showcaseApp
//
//  Created by Alexander Kaplan on 7/6/16.
//  Copyright © 2016 develop. All rights reserved.
//

import UIKit

class MaterialBarButton: UIBarButtonItem {
    
    override func awakeFromNib() {
        if let font = UIFont(name: "NotoSans", size: 15) {
            self.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        self.tintColor = UIColor.whiteColor()
    }
}
