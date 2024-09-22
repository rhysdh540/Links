//
//  LinksApp.swift
//  Links Watch App
//
//  Created by Rhys de Haan on 9/22/24.
//

import SwiftUI

extension UserDefaults {
    static var group: UserDefaults {
        return UserDefaults(suiteName: "dev.rdh.Links")!
    }
}

@main
struct Links_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
