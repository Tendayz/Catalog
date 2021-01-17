//
//  ButtonWithImage.swift
//  Catalog
//
//  Created by Stepan Grachev on 17.01.2021.
//

import UIKit

class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(.allCorners, radius: 5)
        if imageView != nil {
            imageView?.contentMode = .scaleAspectFit
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 40), bottom: 5, right: 20)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!+24)
        }
    }
}
