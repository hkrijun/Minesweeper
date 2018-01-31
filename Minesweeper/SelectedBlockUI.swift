//
//  SelectedTileUI.swift
//  Minesweeper
//
//  Created by Koulutus on 07/11/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

protocol SelectedBlockUIDelegate {
	func BlockOpenClicked()
	func BlockFlagClicked(hasFlag: Bool)
	func HideSelectedBlockUI()
}

class SelectedBlockUI {
	
	// -- Button identifiers
	
	private enum Btn {
		static let Open : Int = 0
		static let Flag : Int = 1
		
		static let AddFlag : Int = 0
		static let RemoveFlag : Int = 1
	}

	// -- Private variables
	
	private var m_buttons : [Button] = [Button]()
	private var m_flagGraphics : [UIImage] = [UIImage]()
	
	private var m_selectedBlockIndicator : UIImageView
	private var m_highlight : UIButton
	private var m_animateHighlight : Bool = false
	private var m_disableHightlight : Bool = true // Currently not used due to poor performance of animating alpha channel

	private var m_view : UIView

	private var m_tileWidth : CGFloat
	private var m_uiButtonSize : CGFloat
	
	var delegate : SelectedBlockUIDelegate?
	
	init(_ view: UIView) {
		m_view = view
		m_tileWidth = CGFloat(GraphicsManager.sharedInstance.tileSize)
		m_uiButtonSize = CGFloat(GraphicsManager.sharedInstance.uiButtonSize)
		
		// -- Set flag button graphics
		
		m_flagGraphics.append(GraphicsManager.sharedInstance.uiAddFlagGraphic!)
		m_flagGraphics.append(GraphicsManager.sharedInstance.uiRemoveFlagGraphic!)
		
		// -- Create selected block indicator
		
		m_selectedBlockIndicator = UIImageView(frame: CGRect(x: 0, y: 0, width: GraphicsManager.sharedInstance.tileSize, height: GraphicsManager.sharedInstance.tileSize))
		m_selectedBlockIndicator.image = GraphicsManager.sharedInstance.selectedBlockGraphic!
		
		view.addSubview(m_selectedBlockIndicator)
		
		// -- Highlight
		
		m_highlight = UIButton(frame: CGRect(x: 0, y: 0, width: HighlightGraphic.intendedWidth, height: HighlightGraphic.intendedHeight))
		m_highlight.setBackgroundImage(GraphicsManager.sharedInstance.highlightGraphic, for: .normal)
		m_highlight.isUserInteractionEnabled = false

		view.addSubview(m_highlight)
		
		// -- Buttons
		
		let openGraphicSize = GraphicsManager.sharedInstance.uiOpenGraphic!.size

		m_buttons.append(Button(m_view, button: UIButton(frame: CGRect(x: 0, y: 0, width: openGraphicSize.width, height: openGraphicSize.height)),
		                      		  animXOffset: 0, animYOffset: -openGraphicSize.height + m_tileWidth * 0.25,
		                      		  image: GraphicsManager.sharedInstance.uiOpenGraphic!) )
		
		let flagGraphicSize = m_flagGraphics[Btn.AddFlag].size
		
		m_buttons.append(Button(m_view, button: UIButton(frame: CGRect(x: 0, y: 0, width: flagGraphicSize.width, height: flagGraphicSize.height)),
		                     animXOffset: 0, animYOffset: m_tileWidth - m_tileWidth * 0.25,
		                     image: m_flagGraphics[Btn.AddFlag]) )
		
		// -- Bind actions
		
		m_buttons[Btn.Open].button.addTarget(self, action: #selector(OpenClicked), for: .touchUpInside)
		m_buttons[Btn.Flag].button.addTarget(self, action: #selector(FlagClicked), for: .touchUpInside)
		//highlight.addTarget(self, action: #selector(HighlightClicked), for: UIControlEvents.touchUpInside)
		
		Hide(skipAnimation: true)
	}
	
	// -- Button actions:
	
	@objc func OpenClicked() {
		delegate?.BlockOpenClicked()
	}
	
	@objc func FlagClicked() {
		delegate?.BlockFlagClicked(hasFlag: false)
	}
	
	@objc func HighlightClicked() {
		delegate?.HideSelectedBlockUI()
	}
	
	// Show UI at Pos (scroll), called by GameViewController
	
	func ShowAt(pos: Pos, hasFlag: Bool) {
		m_buttons[Btn.Flag].Set(image: m_flagGraphics[(hasFlag ? Btn.RemoveFlag : Btn.AddFlag)])
		
		let sizeDifference = m_uiButtonSize - m_tileWidth
		let centeredPosition = Pos(pos.x - sizeDifference * 0.5, pos.y)
		
		for btn in m_buttons {
			btn.Set(pos: centeredPosition)
			btn.Set(hidden: false)
		}
		
		m_highlight.frame.origin = CGPoint(x: -m_highlight.frame.width * 0.5 + CGFloat(pos.x) + m_tileWidth * 0.5,
		                                 y: -m_highlight.frame.height * 0.5 + CGFloat(pos.y) + m_tileWidth * 0.5)
		m_highlight.isHidden = m_disableHightlight
		
		if hasFlag {
			m_buttons[Btn.Open].Set(hidden: true)
		}
		
		if !m_animateHighlight {
			self.m_highlight.alpha = 1
		}
		
		m_selectedBlockIndicator.frame.origin = CGPoint(x: pos.x, y: pos.y)
		m_selectedBlockIndicator.isHidden = false
		
		UIView.animate(
			withDuration: 2,
			delay: 0,
			usingSpringWithDamping: CGFloat(0.30),
			initialSpringVelocity: CGFloat(12.0),
			options: UIViewAnimationOptions.allowUserInteraction,
			animations: {
				for btn in self.m_buttons {
					btn.SetForShowAnim()
				}
				
				if self.m_animateHighlight {
					self.m_highlight.alpha = 1
				}
			},
			completion: { Void in()  }
		)
	}
	
	// Hide UI, called by GameViewController
	
	func Hide(skipAnimation : Bool = false) {
		if !m_animateHighlight {
			self.m_highlight.alpha = 0
		}
		
		m_selectedBlockIndicator.isHidden = true
		
		if skipAnimation {
			for btn in self.m_buttons {
				btn.Set(hidden: true)
			}
			
			if m_animateHighlight {
				self.m_highlight.alpha = 0
			}
			
			m_highlight.isHidden = true
		} else {
			UIView.animate(
				withDuration: 0.25,
				animations: {
					for btn in self.m_buttons {
						btn.SetForHideAnim()
					}
					
					if self.m_animateHighlight {
						self.m_highlight.alpha = 0
					}
				},
				completion: { Void in
					for btn in self.m_buttons {
						btn.Set(hidden: true)
					}
					
					self.m_highlight.isHidden = true
				}
			)
		}
		
	}
	
}
