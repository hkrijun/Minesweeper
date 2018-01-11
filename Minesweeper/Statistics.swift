//
//  Statistics.swift
//  Minesweeper
//
//  Created by Henri on 10/01/2018.
//  Copyright © 2018 Koulutus. All rights reserved.
//

import Foundation

class Statistics {
	
	let SCORES_PER_LIST : Int = 5
	
	static let sharedInstance = Statistics()

	// -- Private variables
	
	private var m_totalSecondsPlayed : Int = 0
	private var m_gamesWon : Int = 0
	private var m_gamesLost : Int = 0
	private var m_gamesRestarted : Int = 0
	
	private var m_scoreLists = [[Score]]()
	
	private let m_settings = UserDefaults.standard
	
	// -- Data definitions
	
	struct Score {
		var name : String
		var seconds : Int
	}
	
	enum EndType {
		case Won, Lost, Restarted
	}
	
	enum ScoreList : Int {
		case NormalMap = 0, LargeMap = 1
	}
	
	enum Settings {
		static let totalSecondsPlayed = "totalSecondsPlayed"
		static let gamesWon = "gamesWon"
		static let gamesLost = "gamesLost"
		static let gamesRestarted = "gamesRestarted"
		static let scoreLists = "scoreLists"
	}
	
	// -- Data saving and restoring
	
	private init() {
		LoadSettings()
	}
	
	private func LoadSettings() {
		m_totalSecondsPlayed = m_settings.integer(forKey: Settings.totalSecondsPlayed)
		m_gamesWon = m_settings.integer(forKey: Settings.gamesWon)
		m_gamesLost = m_settings.integer(forKey: Settings.gamesLost)
		m_gamesRestarted = m_settings.integer(forKey: Settings.gamesRestarted)
		m_scoreLists = m_settings.object(forKey: Settings.scoreLists) as? [[Score]] ?? [[Score]]()
	}
	
	private func SaveSettings() {
		SaveStats()
		SaveScores()
	}
	
	private func SaveStats() {
		m_settings.set(m_totalSecondsPlayed, forKey: Settings.totalSecondsPlayed)
		m_settings.set(m_gamesWon, forKey: Settings.gamesWon)
		m_settings.set(m_gamesLost, forKey: Settings.gamesLost)
		m_settings.set(m_gamesRestarted, forKey: Settings.gamesRestarted)
	}
	
	private func SaveScores() {
		m_settings.set(m_scoreLists, forKey: Settings.scoreLists)
	}
	
	// -- Functions
	
	var gamesWon : Int {
		get { return m_gamesWon }
	}
	
	var gamesLost : Int {
		get { return m_gamesLost }
	}
	
	var totalSecondsPlayed : Int {
		get { return m_totalSecondsPlayed }
	}
	
	var totalTimePlayed : String {
		get { return Format(secondsToTime: m_totalSecondsPlayed) }
	}
	
	var totalGamesPlayed : Int {
		get { return m_gamesWon + m_gamesLost + m_gamesRestarted }
	}
	
	var averageGameTimeInSeconds : Int {
		get { return totalGamesPlayed < 1 ? 0 : m_totalSecondsPlayed / totalGamesPlayed }
	}
	
	var averageGameTime : String {
		get { return Format(secondsToTime: averageGameTimeInSeconds) }
	}
	
	func GameFinished(secondsPlayed: Int, endTo: EndType, mapSize: ScoreList) -> Int {
		var positionOnScoreList = -1
		m_totalSecondsPlayed += secondsPlayed
		
		switch (endTo) {
		case .Lost:
			m_gamesLost += 1
		case .Restarted:
			m_gamesRestarted += 1
		case .Won:
			m_gamesWon += 1
			positionOnScoreList = ProposeScore(toList: mapSize, seconds: secondsPlayed)
		}
		
		return positionOnScoreList
	}
	
	private func ProposeScore(toList _scoreList: ScoreList, seconds: Int) -> Int {
		let scoreLists = Get(scoreList: _scoreList)
		
		if scoreLists.count < SCORES_PER_LIST {
			return scoreLists.count
		}
		
		for i in 0..<scoreLists.count {
			if scoreLists[i].seconds > seconds {
				return i
			}
		}
		
		return -1
	}
	
	func AddScore(toList _scoreList: ScoreList, position: Int, name: String, seconds: Int) {
		var scoreList = Get(scoreList: _scoreList)
		
		scoreList.insert(Score(name: name, seconds: seconds), at: position)
		
		if scoreList.count > SCORES_PER_LIST {
			scoreList.removeLast()
		}
	}

	private func Get(scoreList: ScoreList) -> [Score] {
		let scoreListNum = scoreList.rawValue
		
		repeat {
			m_scoreLists.append([Score]())
		} while m_scoreLists.count < scoreListNum
		
		return m_scoreLists[scoreListNum]
	}
	
	private func Format(secondsToTime seconds: Int) -> String {
		let time = TimeInterval(seconds)
		let hours = Int(time) / 3600
		let minutes = Int(time) / 60 % 60
		let seconds = Int(time) % 60
		
		return hours > 0 ? String(format: "%02i:%02i:%02i", hours, minutes, seconds) : String(format: "%02i:%02i", minutes, seconds)
	}
	
}
