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
	
	var m_gameViewController : GameViewController?

	private var m_menus : [Menu] = [Menu]()
	private var m_stats : [MenuStat] = [MenuStat]()
	
	enum MenuID : Int {
		case main = 0, newGame, topListChoice, normalTopList, largeTopList // DON'T FORGET COUNT!
		
		static let count : Int = 5
	}
	
	func MenuBy(id: MenuID) -> Menu {
		return m_menus[id.rawValue]
	}
	
	func Define(menu: MenuID, parent: MenuID) {
		MenuBy(id: menu).parent = MenuBy(id: parent)
	}
	
	// -- "Constructor"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		backgroundHighlight.image = GraphicsManager.sharedInstance.highlightGraphic

		ConstructStats()
		view.bringSubview(toFront: backgroundHighlight)
		view.bringSubview(toFront: menuImage)
		view.bringSubview(toFront: logoLabel)
		ConstructMenus()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//self.viewDidAppear()
		
		let main = MenuBy(id: .main)
		
		if !main.IsOpen() {
			main.Open()
			ShowStats()
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		Menu.xPosition = menuImage.frame.origin.x + menuImage.frame.width + Menu.margins
		MenuOption.viewWidth = view.bounds.width
		MenuOption.viewHeight = view.bounds.height
		
		PositionMenuOptions()
		PositionStats()
	}

	func PositionMenuOptions() {
		let breadcrumpPos = Pos(menuImage.frame.origin.x + menuImage.frame.width, menuImage.frame.origin.y + menuImage.frame.height * 0.5)

		for i in 0..<m_menus.count {
			m_menus[i].UpdateOptionPositions(breadcrump: breadcrumpPos)
		}
	}
	
	func PositionStats() {
		
	}
	
	func ShowStats() {
		var delay : Double = 0.1
		
		for stat in m_stats {
			stat.Show(delay)
			delay += 0.1
		}
	}
	
	func HideStats() {
		var delay : Double = 0.1
		
		for stat in m_stats {
			stat.Hide(delay)
			delay += 0.1
		}
	}
	
	func ConstructMenus() {
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
		
		m_menus.insert(Menu("normal", backButton: "Back", backButtonType: .back, view: view), at: MenuID.normalTopList.rawValue)
		MenuBy(id: .normalTopList).Add(options: [ (title: "Test 2:43", action: #selector(TopListEntryClicked)) ],
		                               backButtonAction: #selector(BackFromNormalTopListClicked), target: self)
		Define(menu: .normalTopList, parent: .topListChoice)
		
		// -- Large Top List Menu
		
		m_menus.insert(Menu("large", backButton: "Back", backButtonType: .back, view: view), at: MenuID.largeTopList.rawValue)
		MenuBy(id: .largeTopList).Add(options: [ (title: "Test Large 31:02", action: #selector(TopListEntryClicked)) ],
		                               backButtonAction: #selector(BackFromLargeTopListClicked), target: self)
		Define(menu: .largeTopList, parent: .topListChoice)

	}
	
	func ConstructStats() {
		let stats : [(title: String, value: String)] = [
			(title: "AVERAGE GAME LENGTH", value: Statistics.sharedInstance.averageGameTime),
			(title: "TOTAL TIME PLAYED", value: Statistics.sharedInstance.totalTimePlayed),
			(title: "GAMES LOST", value: "\(Statistics.sharedInstance.gamesLost)"),
			(title: "GAMES WON", value: "\(Statistics.sharedInstance.gamesWon)"),
			(title: "GAMES PLAYED", value: "\(Statistics.sharedInstance.totalGamesPlayed)")
		]
		var nextItemPos = Pos(20, view.bounds.size.height * 0.875)
		
		for (title, value) in stats {
			m_stats.append( MenuStat(title: title, value: value, view: view) )

			m_stats.last!.Set(width: view.bounds.width - 40)
			m_stats.last!.Set(pos: nextItemPos)
			
			nextItemPos.y = m_stats.last!.GetPos().y - m_stats.last!.GetHeight() - 5
			
			if m_stats.count == 2 { // Extra offset after Total Time Played
				nextItemPos.y -= 20
			}
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
		HideStats()
		MenuBy(id: .main).Close(keepBreadcrump: false, durationMultiplier: 0.25, delayMultiplier: 0.25)
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
			self.performSegueToReturnBack(kCATransitionFromLeft)
		}
	}

	// -- New Game buttons
	
	@objc func NormalNewGameClicked() {
		if let gameView = m_gameViewController {
			Close(menu: .newGame)
			
			let gameState = gameView.GetGameState()
			
			if gameState.playing {
				_ = Statistics.sharedInstance.GameFinished(secondsPlayed: gameState.secondsPlayed, endTo: .Restarted, mapSize: .NormalMap)
			}
			
			gameView.StartNewGame()
		}
	}
	
	@objc func LargeNewGameClicked() {
		
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
		
	}
	
	// -- Others
	
	func Close(menu: MenuID) {
		MenuBy(id: menu).Close(keepBreadcrump: false, durationMultiplier: 0.25, delayMultiplier: 0.25)
		
		self.performSegueToReturnBack(kCATransitionFromLeft)
	}
	
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
