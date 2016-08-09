//
//  ProfileTextField.swift
//  showcaseApp
//
//  Created by Alexander Kaplan on 7/7/16.
//  Copyright © 2016 develop. All rights reserved.
//

import UIKit

class ProfileTextField: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderWidth = 0
    }
    
    //For placeholder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
    //Editable Text
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
}
