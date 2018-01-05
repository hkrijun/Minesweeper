//
//  ViewControllers.swift
//  Minesweeper
//
//  Created by Henri on 08/12/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

extension UIViewController {
	
	static var TRANSITION_DURATION : Double {
		get { return 0.25 }
	}
	
	// From -> https://stackoverflow.com/questions/38741556/ios-how-to-simple-return-back-to-previous-presented-pushed-view-controller-progr
	// And -> https://stackoverflow.com/questions/38799143/dismiss-view-controller-with-custom-animation
	
	func performSegueToReturnBack(_ transitionSubType: String)  {
		if let nav = self.navigationController {
			nav.popViewController(animated: true)
		} else {
			let transition: CATransition = CATransition()
			transition.duration = UIViewController.TRANSITION_DURATION
			transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			transition.type = kCATransitionReveal
			transition.subtype = transitionSubType
			self.view.window!.layer.add(transition, forKey: nil)
			
			//let parent = self.presentingViewController

			self.dismiss(animated: false, completion: nil)
			
			if let parent = self.presentingViewController {
				parent.childDismissed()
			}
		}
	}
	
	func childDismissed() {}

}
