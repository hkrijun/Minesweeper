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
	
	var m_gameViewController : GameViewController?

	private var m_menus : [Menu] = [Menu]()
	
	enum MenuID : Int {
		case main = 0, newGame, topListChoice, normalTopList, largeTopList, exitGame
		
		static let count : Int = 6
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

		ConstructMenus()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//self.viewDidAppear()
		
		let main = MenuBy(id: .main)
		
		if !main.IsOpen() {
			main.Open()
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		Menu.xPosition = menuImage.frame.origin.x + menuImage.frame.width + Menu.margins
		MenuOption.viewWidth = view.bounds.width
		MenuOption.viewHeight = view.bounds.height
		
		PositionMenuOptions()
	}

	func PositionMenuOptions() {
		let breadcrumpPos = Pos(menuImage.frame.origin.x + menuImage.frame.width, menuImage.frame.origin.y + menuImage.frame.height * 0.5)

		for i in 0..<m_menus.count {
			m_menus[i].UpdateOptionPositions(breadcrump: breadcrumpPos)
		}
	}
	
	func ConstructMenus() {
		m_menus.removeAll()
		m_menus.reserveCapacity(MenuID.count)
		
		// -- Main Menu
		
		m_menus.insert(Menu("menu", backButton: "Exit", backButtonType: .exit, view: view), at: MenuID.main.rawValue)
		MenuBy(id: .main).Add(options: [ (title: "New Game", action: #selector(OpenNewGameMenu)),
		                                 (title: "Top List", action: #selector(OpenTopListMenu)),
		                                 (title: "Continue", action: #selector(ContinueClicked)) ],
		                      backButtonAction: #selector(ExitClicked), target: self)
		
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
		
		// -- Exit Menu
		
		m_menus.insert(Menu("exit game", backButton: "Back", backButtonType: .back, view: view), at: MenuID.exitGame.rawValue)
		MenuBy(id: .exitGame).Add(options: [ (title: "Exit", action: #selector(ExitConfirmClicked)) ],
		                         backButtonAction: #selector(BackFromExitGameClicked), target: self)
		Define(menu: .exitGame, parent: .main)
	}
	
	// -- Main Menu buttons
	
	@objc func OpenNewGameMenu() {
		MenuBy(id: .main).SwitchTo(menu: MenuBy(id: .newGame), isLowerMenu: true)
	}
	
	@objc func OpenTopListMenu() {
		MenuBy(id: .main).SwitchTo(menu: MenuBy(id: .topListChoice), isLowerMenu: true)
	}
	
	@objc func ContinueClicked() {
		MenuBy(id: .main).Close(keepBreadcrump: false, durationMultiplier: 0.25, delayMultiplier: 0.25)
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
			self.performSegueToReturnBack(kCATransitionFromLeft)
		}
	}
	
	@objc func ExitClicked() {
		MenuBy(id: .main).SwitchTo(menu: MenuBy(id: .exitGame), isLowerMenu: true)
	}
	
	// -- New Game buttons
	
	@objc func NormalNewGameClicked() {
		if let gameView = m_gameViewController {
			Close(menu: .newGame)
			gameView.StartNewGame()
		}
	}
	
	@objc func LargeNewGameClicked() {
		
	}
	
	@objc func BackFromNewGameClicked() {
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
	
	// -- Exit Menu buttons
	
	@objc func ExitConfirmClicked() { }
	
	@objc func BackFromExitGameClicked() {
		MenuBy(id: .exitGame).SwitchTo(menu: MenuBy(id: .main), isLowerMenu: false)
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
