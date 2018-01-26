//
//  PrettyView.swift
//  Minesweeper
//
//  Created by Henri on 23/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import UIKit

// Mostly from: https://www.thedroidsonroids.com/blog/ios/ibdesignable-and-ibinspectable/

@IBDesignable class PrettyView: UIView {

	@IBInspectable var cornerRadius: CGFloat = 0.0 {
		didSet {
			let maxRadius = frame.width > frame.height ? frame.height : frame.width
			layer.cornerRadius = maxRadius * cornerRadius * 0.5
		}
	}
	
	@IBInspectable var borderColor: UIColor = .clear {
		didSet {
			layer.borderColor = borderColor.cgColor
		}
	}
	
	@IBInspectable var borderWidth: CGFloat = 0.0 {
		didSet {
			layer.borderWidth = borderWidth
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.masksToBounds = true
	}

}
