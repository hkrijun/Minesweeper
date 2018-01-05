//
//  MenuImage.swift
//  Minesweeper
//
//  Created by Henri on 11/12/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

@IBDesignable class MenuImage: UIImageView {

	@IBInspectable var imageID : Int = 0
	
	let images : [UIImage?] = [GraphicsManager.sharedInstance.menuBombGraphic]
	
	override func layoutSubviews() {
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
		self.image = images[imageID] //GetImageBy(id: imageID)
	}
	
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
