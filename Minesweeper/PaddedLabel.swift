//
//  PaddedLabel.swift
//  Minesweeper
//
//  Created by Henri on 11/12/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

@IBDesignable class PaddedLabel: UILabel {
	
	@IBInspectable var southbound : Bool = false {
		didSet {
			if self.southbound {
				self.transform = translateRotateFlip()
			}
			
			//self.setNeedsUpdateConstraints()
			self.setNeedsLayout()
		}
	}
	
	@IBInspectable var topInset: CGFloat = 5.0
	@IBInspectable var bottomInset: CGFloat = 5.0
	@IBInspectable var leftInset: CGFloat = 5.0
	@IBInspectable var rightInset: CGFloat = 5.0
	
	override func drawText(in rect: CGRect) {
		let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
		
		super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
	}
	
	override var intrinsicContentSize: CGSize {
		get {
			var contentSize = super.intrinsicContentSize
			
			contentSize.height += topInset + bottomInset
			contentSize.width += leftInset + rightInset
			/*
			if self.southbound {
				let height = contentSize.height
				
				contentSize.height = contentSize.width
				contentSize.width = height
			}
			*/
			return contentSize
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		if self.southbound {
			self.transform = translateRotateFlip()
		}
	}
	
	func translateRotateFlip() -> CGAffineTransform {
		var transform = CGAffineTransform.identity
		let height = self.bounds.height

		transform = transform.translatedBy(x: -self.bounds.size.width * 0.5 + height * 0.5, y: self.bounds.size.width * 0.5 - height * 0.5)
		transform = transform.rotated(by: CGFloat(CGFloat.pi * 0.5))

		return transform
	}
	
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
