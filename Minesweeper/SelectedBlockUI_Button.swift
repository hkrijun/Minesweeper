//
//  SelectedTileUI_Button.swift
//  Minesweeper
//
//  Created by Henri on 27/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

extension SelectedBlockUI {
	class Button {
	 	var button : UIButton
		
		private var m_animXOffset : CGFloat
		private var m_animYOffset : CGFloat
		
		init(_ view: UIView, button: UIButton, animXOffset: CGFloat, animYOffset: CGFloat, image: UIImage) {
			self.button = button
			m_animXOffset = animXOffset
			m_animYOffset = animYOffset
			
			Set(image: image)
			view.addSubview(self.button)
		}
		
		func SetPos(_ x: CGFloat, _ y: CGFloat) {
			button.frame.origin.x = x
			button.frame.origin.y = y
		}
		
		func Set(pos: Pos) {
			SetPos(pos.x, pos.y)
		}
		
		func Set(hidden: Bool) {
			button.isHidden = hidden
		}
		
		func SetForShowAnim() {
			if !button.isHidden {
				//button.frame.origin.x = button.frame.origin.x + x_offset
				button.frame.origin.y = button.frame.origin.y + m_animYOffset
				
				//button.alpha = 1
			}
		}
		
		func SetForHideAnim() {
			if !button.isHidden {
				button.frame.origin.y = button.frame.origin.y - m_animYOffset
				
				//button.alpha = 0
			}
		}
		
		func Set(image: UIImage) {
			button.setBackgroundImage(image, for: .normal)
		}
		
	}
}
