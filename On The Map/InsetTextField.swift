//
//  InsetTextField.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/20.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {

    var inset: CGFloat = 12.0
    
    override init(frame: CGRect) {

        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)!
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {

        return CGRectInset(bounds, inset, inset)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        
        return CGRectInset(bounds, inset, inset)
    }
}
