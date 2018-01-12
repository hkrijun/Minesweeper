//
//  ViewController.swift
//  Minesweeper
//
//  Created by Koulutus on 27/09/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

protocol GameViewControllerDelegate {
	func FrameUpdate(deltaTime: Double)
}

class GameViewController: UIViewController, MinefieldDelegate, SelectedBlockUIDelegate {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var plotsLabel: UILabel!
	@IBOutlet weak var plotsSubLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	
	private enum label { // Label ID
		static let plots : Int = 0
		static let percent : Int = 1
	}
	
	var m_delegate : GameViewControllerDelegate?
	
	var m_animatingLabels = [ AnimateValue(), AnimateValue() ]
	
	var m_displayLink : CADisplayLink?
	var m_timer : Timer?
	var m_seconds : Int = 0
	var m_timerPaused : Bool = true
	
	var m_minefield : Minefield?
	var m_selectedBlock : Block?
	var m_selectedBlockUI : SelectedBlockUI?
	var m_previousClearBlocks : Int?
	var m_lastSeletedBlockPosition = Pos(0, 0)
	
	private var lastScrollToTargetPos : Pos = Pos()
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let boardSize = CGSize(width: 1500, height: 1500) // view.bounds.size
		let mineSize : Int = 50
		
		scrollView.contentSize = boardSize
		scrollView.canCancelContentTouches = false

		GraphicsManager.sharedInstance.SetScreen(width: Int(view.bounds.size.width), height: Int(view.bounds.size.height))
		GraphicsManager.sharedInstance.RenderGraphics(mineSize)

		m_minefield = Minefield( Int(boardSize.width), Int(boardSize.height), mineSize, mineSize )
		m_minefield!.Create(scrollView, delegate: self)
		
		m_selectedBlockUI = SelectedBlockUI(scrollView)
		m_selectedBlockUI?.delegate = self
		
		m_delegate = m_minefield
		
		m_displayLink = CADisplayLink(target: self, selector: #selector(UpdateUILabels))
		m_displayLink?.add(to: .current, forMode: .commonModes)
	}
	
	// -- New Game
	
	func StartNewGame(mapSize: Int = 30) {
		let blockSize : Int = 50 // TODO: calculate from res+dpi https://github.com/marchv/UIScreenExtension
		let boardSize = CGSize(width: mapSize * blockSize, height: mapSize * blockSize)

		scrollView.contentSize = boardSize
		
		m_minefield!.SetParameters(width: mapSize * blockSize, height: mapSize * blockSize, blockSize: blockSize)
		m_minefield!.Create(scrollView)
		
		StopTimers()
		m_seconds = -1
		m_timerPaused = false
		UpdateTimeLabel()
		m_timerPaused = true
		
		ScrollTo(x: 0, y: 0, animated: false, adhereToLimits: true)
	}
	
	// -- Ran during screen refreshes (something better?)

	func UpdateUILabels() {
		let deltaTime : Double = abs((m_displayLink?.targetTimestamp)! - (m_displayLink?.timestamp)!) // (m_displayLink?.duration)! // Possibly not working as expected (always same as target frequency?)

		if m_animatingLabels[label.plots].Animate(deltaTime: deltaTime) {
			let trimmed = Int(m_animatingLabels[label.plots].GetValue())
			
			plotsLabel.text = "\(trimmed)"
		}
		
		if m_animatingLabels[label.percent].Animate(deltaTime: deltaTime) {
			let percentFormatter = NumberFormatter()
			
			percentFormatter.minimumIntegerDigits = 1
			percentFormatter.minimumFractionDigits = 2
			percentFormatter.maximumFractionDigits = 2

			let percent = NSNumber(value: m_animatingLabels[label.percent].GetValue())
			
			plotsSubLabel.text = "\(percentFormatter.string(from: percent) ?? "0.00")%"
		}
		
		m_delegate?.FrameUpdate(deltaTime: deltaTime)
	}
	
	// -- Time(r)
	
	func StartTimers() {
		m_timerPaused = false
		m_timer = Timer.scheduledTimer(timeInterval: 1, target: self,  selector: (#selector(GameViewController.UpdateTimeLabel)), userInfo: nil, repeats: true)
	}
	
	func UpdateTimeLabel() {
		if !m_timerPaused {
			m_seconds += 1

			let time = TimeInterval(m_seconds)
			let hours = Int(time) / 3600
			let minutes = Int(time) / 60 % 60
			let seconds = Int(time) % 60
			
			timeLabel.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
		}
	}
	
	func StopTimers() {
		m_timer?.invalidate()
		m_timer = nil
		m_timerPaused = true
	}
	
	// -- Minefield delegate:
	
	func BlockClicked(_ block: Block) {
		if IsSelectedBlockUIVisible() {
			if block.IsMystery() {
				m_selectedBlock = block
				m_lastSeletedBlockPosition = block.Position()
		
				let minePos = block.Position()

				m_selectedBlockUI?.ShowAt(pos: minePos, hasFlag: block.HasFlag())
				ScrollTo(x: minePos.x, y: minePos.y)
				scrollView.isScrollEnabled = false
			}
		} else {
			HideSelectedBlockUI()
		}
	}
	
	func RemainingBlockCountChanged(clearBlocks: Int, mines: Int) {
		m_animatingLabels[label.plots].Update(target: Double(clearBlocks))
		m_animatingLabels[label.percent].Update(target: (clearBlocks == 0 ? 0 : Double(clearBlocks) / Double(clearBlocks + mines) * 100.0))

		if m_previousClearBlocks != nil {
			let clearedBlocks = m_previousClearBlocks! - clearBlocks
			let startPos = m_lastSeletedBlockPosition + Pos(CGFloat(GraphicsManager.sharedInstance.tileSize) * 0.5)
			//let direction = (Pos(scrollView.contentSize.width * 0.5, scrollView.contentSize.height * 0.5) - startPos).Normalized()
			//startPos = startPos + direction * (CGFloat(GraphicsManager.sharedInstance.tileSize) * 0.25)
			
			ShowFadingNotification("\(clearedBlocks)", color: UIColor.white, size: CGFloat(GraphicsManager.sharedInstance.tileSize * 3), endScale: 0.01,
			                       start: startPos, end: GetScrollPos(), //startPos + direction * (CGFloat(GraphicsManager.sharedInstance.tileSize) * 0.25),
			                       duration: 1.5, easeInDuration: 0.75)
		} else {
			m_animatingLabels[label.plots].Update(current: Double(clearBlocks))
			m_animatingLabels[label.percent].Update(current: Double(clearBlocks) / Double(clearBlocks + mines) * 100.0 )
		}
		
		m_previousClearBlocks = clearBlocks
		
		if clearBlocks == 0 {
			PlayerWins()
		}
	}
	
	// Game over
	
	func HitBomb() {
		StopTimers()
		
		let textPos = GetScrollPos() + Pos(scrollView.frame.width * 0.5, scrollView.frame.height * 0.5)
		ShowFadingNotification("GAME OVER", color: UIColor(red: 0.65, green: 0, blue: 0, alpha: 1),
		                       size: scrollView.frame.width / 5, endScale: 3,
		                       start: textPos, end: nil,
		                       duration: 10, easeInDuration: 0.5)
	}
	
	func PlayerWins() {
		StopTimers()
	}
	
	// Selected tile ui delegate:
	
	func BlockOpenClicked() {
		if let block = m_selectedBlock {
			self.m_minefield?.CheckBlock(block.m_location)
			HideSelectedBlockUI()
			
			if m_timer == nil {
				StartTimers()
			}
		}
	}
	
	func BlockFlagClicked(hasFlag: Bool) {
		if let block = m_selectedBlock {
			block.ToggleFlag()
			HideSelectedBlockUI()
		}
	}
	
	func HideSelectedBlockUI() {
		m_selectedBlock = nil
		scrollView.isScrollEnabled = true
		m_selectedBlockUI?.Hide()
	}
	
	// Fading notification
	
	func ShowFadingNotification(_ message : String, color: UIColor, size: CGFloat, endScale: CGFloat?, start: Pos, end: Pos?, duration: Double, easeInDuration: Double, delay: Double = 0, toScrollView: Bool = true) {
		let label = UILabel()
		label.text = message
		label.backgroundColor = UIColor.clear
		label.textColor = color
		label.textAlignment = .center;
		label.font = UIFont(name: GraphicsManager.sharedInstance.graphicsFont!, size: size)
		label.sizeToFit()
		label.isUserInteractionEnabled = false
		
		if toScrollView {
			scrollView.addSubview(label)
		} else {
			view.addSubview(label)
		}
		
		label.frame.origin = CGPoint(x: start.x - label.frame.size.width * 0.5, y: start.y - label.font.lineHeight * 0.5)
		label.transform = label.transform.scaledBy(x: 0.1, y: 0.1)
		//label.alpha = CGFloat(0) // Removed: too slow

		UIView.animate(withDuration: easeInDuration, delay: 0, options: .curveEaseIn, animations: {
			label.transform = label.transform.scaledBy(x: 10, y: 10)
			//label.alpha = CGFloat(1)
		}, completion: {(isCompleted) in
			UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
				if end != nil {
					label.frame.origin = CGPoint(x: end!.x - label.frame.size.width * 0.5, y: end!.y - label.font.lineHeight * 0.5)
				}
				
				if endScale != nil {
					label.transform = label.transform.scaledBy(x: endScale!, y: endScale!)
				}
				
				//label.alpha = CGFloat(0)
			}, completion: {(isCompleted) in
				label.removeFromSuperview()
			})
		})
	}
	
	// Menu animations
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let pos = GetScrollPos() + Pos(view.bounds.size) * 0.5
		
		if let target = segue.destination as? MainMenuViewController { // if segue.identifier == "gameToMenu" {
			ScrollTo(x: pos.x + view.bounds.size.width * 0.5, y: pos.y, animated: true, adhereToLimits: false)
			
			target.m_gameViewController = self
			m_timerPaused = true
		}
	}
	
	override func childDismissed() {
		ScrollTo(x: lastScrollToTargetPos.x, y: lastScrollToTargetPos.y, animated: false, adhereToLimits: false) // Scrolling beyond limits doesn't seem to stay beyond view transitions
		
		let pos = GetScrollPos() + Pos(view.bounds.size) * 0.5

		ScrollTo(x: pos.x - view.bounds.size.width * 0.5, y: pos.y, animated: true, adhereToLimits: false)
		m_timerPaused = false
	}
	
	// Others:

	func ScrollTo(x: CGFloat, y: CGFloat, animated: Bool = true, adhereToLimits: Bool = true) {
		var scrollToX = x - view.bounds.size.width * 0.5
		var scrollToY = y - view.bounds.size.height * 0.5
		
		if adhereToLimits {
			let field = m_minefield!.GetFieldSize()
			
			scrollToX = min(max(0, scrollToX), field.width - view.bounds.size.width)
			scrollToY = min(max(0, scrollToY), field.height - view.bounds.size.height)
		}
		
		if animated {
			UIView.animate(withDuration: UIViewController.TRANSITION_DURATION, delay: 0, options: .curveEaseInOut, animations: {
				self.scrollView.contentOffset = CGPoint(x: scrollToX, y: scrollToY)
			}, completion: nil)
		} else {
			scrollView.contentOffset = CGPoint(x: scrollToX, y: scrollToY)
		}
		//scrollView.setContentOffset(CGPoint(x: scrollToX, y: scrollToY), animated: animated)
		
		lastScrollToTargetPos = Pos(x, y)
	}
	
	func GetScrollPos() -> Pos {
		return Pos( scrollView.contentOffset.x, scrollView.contentOffset.y )
	}
	
	func IsSelectedBlockUIVisible() -> Bool {
		return scrollView.isScrollEnabled
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
		
}

/*
let alert = UIAlertController(title: String(gameState.left), message: nil, preferredStyle: .actionSheet)

alert.addAction(UIAlertAction(title: NSLocalizedString("Dig", comment: "Default action"), style: .destructive, handler: { _ in
self.m_minefield?.CheckMine(pos)
}))
/*
alert.addAction(UIAlertAction(title: NSLocalizedString(m_minefield?.MineAt(pos).HasFlag() ? "Remove flag" : "Add flag", comment: "Default action"), style: .default, handler: { _ in
self.m_minefield?.ToggleFlag(pos)
}))
*/
alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
print("The \"CANCEL\" alert occured.")
}))

self.present(alert, animated: true, completion: nil)
*/

