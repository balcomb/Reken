//
//  Settings.swift
//  Reken
//
//  Created by Ben Balcomb on 3/3/22.
//

import Foundation

protocol SettingsOption: Codable, CaseIterable, Hashable {}

struct Settings: Codable, Equatable {

    var gameType: GameType
    var skillLevel: SkillLevel

    static var standard: Settings { Settings(gameType: .onePlayer, skillLevel: .basic) }
    private static var storageKey = "Reken.Storage.Settings"

    static var stored: Settings? {
        let jsonString = UserDefaults.standard.string(forKey: Self.storageKey)
        guard let jsonData = jsonString?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Settings.self, from: jsonData)
    }

    func getUpdated<O: SettingsOption>(with option: O) -> Settings? {
        var updatedSettings = self
        if let gameType = option as? Settings.GameType {
            updatedSettings.gameType = gameType
        } else if let skillLevel = option as? Settings.SkillLevel {
            updatedSettings.skillLevel = skillLevel
        }
        guard updatedSettings != self else { return nil }
        return updatedSettings
    }

    func store() -> Bool {
        guard let jsonData = try? JSONEncoder().encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return false
        }
        UserDefaults.standard.set(jsonString, forKey: Self.storageKey)
        return true
    }
}

extension Settings {

    enum GameType: String, SettingsOption {
        case onePlayer, twoPlayer
    }

    enum SkillLevel: String, SettingsOption {
        case basic, advanced
    }
}
