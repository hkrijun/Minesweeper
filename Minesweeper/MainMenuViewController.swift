//
//  MainMenuViewController.swift
//  Minesweeper
//
//  Created by Henri on 08/12/2017.
//  Copyright © 2017 Koulutus. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
	
	@IBOutlet weak var backgroundHighlight: UIImageView!
	@IBOutlet weak var menuImage: MenuImage!
	@IBOutlet weak var logoLabel: PaddedLabel!
	@IBOutlet weak var statBar: UIView!
	
	var m_gameViewController : GameViewController? // (MUST BE) Set by creator/parent GameViewController

	// -- Menus
	
	private var m_menus : [Menu] = [Menu]()
	private var m_stats : [MenuStat] = [MenuStat]()
	
	// -- Menu identifiers
	
	private enum MenuID : Int {
		case main = 0, newGame, topListChoice, normalTopList, largeTopList // DON'T FORGET COUNT!
		
		static let count : Int = 5
	}
	
	// -- "Constructor"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		backgroundHighlight.image = GraphicsManager.sharedInstance.highlightGraphic

		ConstructStats()
		view.bringSubview(toFront: backgroundHighlight)
		ConstructMenus()
		view.bringSubview(toFront: menuImage)
		view.bringSubview(toFront: logoLabel)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//self.viewDidAppear(animated)
		
		let main = MenuBy(id: .main)
		
		if !main.IsOpen() {
			main.Open()
			ShowStats(startDelay: 0.125)
		}
	}
	
	// -- Positioning & presentation
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		Menu.xPosition = menuImage.frame.origin.x + menuImage.frame.width + Menu.margins // Position of menu items
		MenuOption.viewWidth = view.bounds.width
		MenuOption.viewHeight = view.bounds.height
		
		PositionMenuOptions()
		PositionStats()
	}

	private func PositionMenuOptions() {
		let breadcrumpPos = Pos(menuImage.frame.origin.x + menuImage.frame.width, menuImage.frame.origin.y + menuImage.frame.height * 0.5)

		for menu in m_menus {
			menu.UpdateOptionPositions(breadcrump: breadcrumpPos)
		}
	}
	
	private func PositionStats() {
		var nextItemPos = Pos(20, statBar.frame.minY)

		for (index, stat) in m_stats.enumerated() {
			stat.Set(width: view.bounds.width - 40)
			stat.Changed(pos: nextItemPos - Pos(y: stat.GetHeight() + 5) )
			
			nextItemPos.y = stat.GetPos().y
			
			if index == 1 { // Extra offset after Total Time Played
				nextItemPos.y -= 20
			}
		}
	}
	
	private func ShowStats(startDelay: Double = 0, delay _delay: Double = 0.1) {
		var delay : Double = startDelay
		
		for stat in m_stats.reversed() {
			stat.Show(delay)
			delay += _delay
		}
	}
	
	private func HideStats(startDelay: Double = 0, delay _delay: Double = 0.1) {
		var delay : Double = startDelay
		
		for stat in m_stats {
			stat.Hide(delay)
			delay += _delay
		}
	}
	
	// -- Construction
	
	private func ConstructMenus() {
		m_menus.removeAll()
		m_menus.reserveCapacity(MenuID.count)
		
		// -- Main Menu
		
		m_menus.insert(Menu("menu", backButton: nil, backButtonType: .exit, view: view), at: MenuID.main.rawValue)
		MenuBy(id: .main).Add(options: [ (title: "New Game", action: #selector(OpenNewGameMenu)),
		                                 (title: "Top List", action: #selector(OpenTopListMenu)),
		                                 (title: "Continue", action: #selector(ContinueClicked)) ],
		                      backButtonAction: nil, target: self)
		
		// -- New Game Menu
		
		m_menus.insert(Menu("new game", backButton: "Back", backButtonType: .back, view: view), at: MenuID.newGame.rawValue)
		MenuBy(id: .newGame).Add(options: [ (title: "Normal", action: #selector(NormalNewGameClicked)),
		                                    (title: "Large", action: #selector(LargeNewGameClicked)) ],
		                         backButtonAction: #selector(BackFromNewGameClicked), target: self)
		Define(menu: .newGame, parent: .main)
		
		// -- Top List Choice Menu
		
		m_menus.insert(Menu("top list", backButton: "Back", backButtonType: .back, view: view), at: MenuID.topListChoice.rawValue)
		MenuBy(id: .topListChoice).Add(options: [ (title: "Normal", action: #selector(NormalTopListClicked)),
		                                          (title: "Large", action: #selector(LargeTopListClicked)) ],
		                         backButtonAction: #selector(BackFromTopListChoiceClicked), target: self)
		Define(menu: .topListChoice, parent: .main)
		
		// -- Normal Top List Menu
		
		let normalListScores = Statistics.sharedInstance.Get(formattedScoreList: .NormalMap)
		
		m_menus.insert(Menu("normal", backButton: "Back", backButtonType: .back, view: view), at: MenuID.normalTopList.rawValue)
		MenuBy(id: .normalTopList).Add(stats: normalListScores,
		                               backButtonAction: #selector(BackFromNormalTopListClicked), target: self)
		Define(menu: .normalTopList, parent: .topListChoice)
		
		// -- Large Top List Menu
		
		let largeListScores = Statistics.sharedInstance.Get(formattedScoreList: .LargeMap)
		
		m_menus.insert(Menu("large", backButton: "Back", backButtonType: .back, view: view), at: MenuID.largeTopList.rawValue)
		MenuBy(id: .largeTopList).Add(stats: largeListScores,
		                              backButtonAction: #selector(BackFromLargeTopListClicked), target: self)
		Define(menu: .largeTopList, parent: .topListChoice)

	}
	
	private func ConstructStats() {
		let stats : [(title: String, value: String)] = [
			(title: "AVERAGE GAME LENGTH", value: Statistics.sharedInstance.averageGameTime),
			(title: "TOTAL TIME PLAYED", value: Statistics.sharedInstance.totalTimePlayed),
			(title: "GAMES LOST", value: "\(Statistics.sharedInstance.gamesLost)"),
			(title: "GAMES WON", value: "\(Statistics.sharedInstance.gamesWon)"),
			(title: "GAMES PLAYED", value: "\(Statistics.sharedInstance.totalGamesPlayed)")
		]
		
		m_stats.removeAll()

		for (title, value) in stats {
			m_stats.append( MenuStat(title: title, value: value, view: view) )
			m_stats.last!.Hide()
		}
	}
	
	// -- Main Menu buttons
	
	@objc func OpenNewGameMenu() {
		HideStats()
		MenuBy(id: .main).SwitchTo(menu: MenuBy(id: .newGame), isLowerMenu: true)
	}
	
	@objc func OpenTopListMenu() {
		HideStats()
		MenuBy(id: .main).SwitchTo(menu: MenuBy(id: .topListChoice), isLowerMenu: true)
	}
	
	@objc func ContinueClicked() {
		HideStats(startDelay: 0, delay: 0.05)
		MenuBy(id: .main).Close(keepBreadcrump: false, durationMultiplier: 0.5, delayMultiplier: 0.5)
		
		Delay(0.1) {
			self.performSegueToReturnBack(kCATransitionFromLeft)
		}
	}

	// -- New Game buttons
	
	@objc func NormalNewGameClicked() {
		if let gameView = m_gameViewController {
			Close(menu: .newGame, noChildDismissedEvent: true)
			
			let gameState = gameView.GetGameState()
			
			if gameState.playing {
				_ = Statistics.sharedInstance.GameFinished(secondsPlayed: gameState.secondsPlayed, endTo: .Restarted, mapSize: .NormalMap)
			}
			
			gameView.StartNewGame(mapType: .NormalMap)
		}
	}
	
	@objc func LargeNewGameClicked() {
		if let gameView = m_gameViewController {
			Close(menu: .newGame, noChildDismissedEvent: true)
			
			let gameState = gameView.GetGameState()
			
			if gameState.playing {
				_ = Statistics.sharedInstance.GameFinished(secondsPlayed: gameState.secondsPlayed, endTo: .Restarted, mapSize: .NormalMap)
			}
			
			gameView.StartNewGame(mapType: .LargeMap)
		}
	}
	
	@objc func BackFromNewGameClicked() {
		ShowStats()
		MenuBy(id: .newGame).SwitchTo(menu: MenuBy(id: .main), isLowerMenu: false)
	}
	
	// -- Top List Choice buttons
	
	@objc func NormalTopListClicked() {
		MenuBy(id: .topListChoice).SwitchTo(menu: MenuBy(id: .normalTopList), isLowerMenu: true)
	}
	
	@objc func LargeTopListClicked() {
		MenuBy(id: .topListChoice).SwitchTo(menu: MenuBy(id: .largeTopList), isLowerMenu: true)
	}
	
	@objc func BackFromTopListChoiceClicked() {
		ShowStats()
		MenuBy(id: .topListChoice).SwitchTo(menu: MenuBy(id: .main), isLowerMenu: false)
	}
	
	// -- Normal Top List buttons
	
	@objc func BackFromNormalTopListClicked() {
		MenuBy(id: .normalTopList).SwitchTo(menu: MenuBy(id: .topListChoice), isLowerMenu: false)
	}
	
	@objc func BackFromLargeTopListClicked() {
		MenuBy(id: .largeTopList).SwitchTo(menu: MenuBy(id: .topListChoice), isLowerMenu: false)
	}
	
	@objc func TopListEntryClicked() {
		// Dummy action
	}
	
	// -- Menu helpers
	
	private func MenuBy(id: MenuID) -> Menu {
		return m_menus[id.rawValue]
	}
	
	private func Define(menu: MenuID, parent: MenuID) {
		MenuBy(id: menu).parent = MenuBy(id: parent)
	}
	
	private func Close(menu: MenuID, noChildDismissedEvent: Bool = false) {
		MenuBy(id: menu).Close(keepBreadcrump: false, durationMultiplier: 0.25, delayMultiplier: 0.25)
		
		Delay(0.1) {
			self.performSegueToReturnBack(kCATransitionFromLeft, noChildDismissedEvent: noChildDismissedEvent)
		}
	}
	
	private func Delay(_ seconds: Double, closure: @escaping () -> () ) {
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
	}
	
	// -- Xcode created
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
