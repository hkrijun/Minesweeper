//
//  SegueFromRight.swift
//  Minesweeper
//
//  Created by Henri on 08/12/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class SegueFromRight: UIStoryboardSegue {
	
	override func perform() {
		let src = self.source
		let dst = self.destination
		
		src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
		dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
		
		let duration : Double = UIViewController.TRANSITION_DURATION
		
		UIView.animate(withDuration: duration,
		               delay: 0.0,
		               options: .curveEaseInOut,
		               animations: {
								dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
		},
		               completion: { finished in
								src.present(dst, animated: false, completion: nil)
		})
	}
	
}
