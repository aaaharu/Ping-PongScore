//
//  Ping_PongScoreApp.swift
//  Ping-PongScore
//
//  Created by 김은지 on 12/29/23.
//

import SwiftUI
import UIKit

@main
struct Ping_PongScoreApp: App {

    @UIApplicationDelegateAdaptor var delegate : PingPongAppDelegate
    @State private var defaultBool = false
    var body: some Scene {
        WindowGroup {
            OpeningView(loadLastGame: defaultBool)
//
//            PurchaseView()
        }
    }
}
