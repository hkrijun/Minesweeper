//
//  HighlightGraphic.swift
//  Minesweeper
//
//  Created by Koulutus on 08/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class HighlightGraphic : GameGraphic {
	
	static let quality : CGFloat = 0.15
	static var intendedWidth : CGFloat = 0
	static var intendedHeight : CGFloat = 0

	override func CreateImage(_ width: Int, height: Int?) -> UIImage? {
		var size = CGSize(width: width, height: height!)
		
		HighlightGraphic.intendedWidth = size.width // * 2
		HighlightGraphic.intendedHeight = size.height // * 2
		
		size.width = size.width * HighlightGraphic.quality
		size.height = size.height * HighlightGraphic.quality
		
		//let hWidth = size.width * 0.5
		//let hHeight = size.height * 0.5
		
		//let tileSize = CGFloat(GraphicsManager.sharedInstance.tileSize) * HighlightGraphic.quality

		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		
		// -- Colours
		
		let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
		let highlightColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
		
		// -- Vars
		
		let edgeBlackSize : CGFloat = size.width * 0.2
		let highlightBlurRadius : CGFloat = size.width * 1
		
		// -- Background
		
		backgroundColor.setFill()
		UIBezierPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height)).fill()
		
		// -- Highlight
		
		highlightColor.setFill()
		UIBezierPath(ovalIn: CGRect(x: edgeBlackSize,
		                            y: edgeBlackSize,
		                            width: size.width - edgeBlackSize * 2,
		                            height: size.height - edgeBlackSize * 2 )).fill(with: .copy, alpha: 1)
		
		// -- Output
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		// -- Blur
		
		let ciimage: CIImage = CIImage(image: image)!
		
		let affineClampFilter = CIFilter(name: "CIAffineClamp")!
		affineClampFilter.setDefaults()
		affineClampFilter.setValue(ciimage, forKey: kCIInputImageKey)
		let resultClamp = affineClampFilter.value(forKey: kCIOutputImageKey)

		let filter: CIFilter = CIFilter(name:"CIGaussianBlur")!
		filter.setDefaults()
		filter.setValue(resultClamp, forKey: kCIInputImageKey)
		filter.setValue(highlightBlurRadius, forKey: kCIInputRadiusKey)
		
		let ciContext = CIContext(options: nil)
		let result = filter.value(forKey: kCIOutputImageKey) as! CIImage!
		let cgImage = ciContext.createCGImage(result!, from: ciimage.extent)
		
		return UIImage(cgImage: cgImage!)
	}
	
}
