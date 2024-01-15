//
//  PingPongAppDelegate.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/9/24.
//

import Foundation
import UIKit
import StoreKit
import GoogleMobileAds


class PingPongAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            print(#fileID, #function, #line, "- <# 주석 #>")
        InAppService.shared.initIAP() // 인앱을 시작함.
        
        GADMobileAds.sharedInstance().start(completionHandler: nil) 

        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // 종료
        print(#fileID, #function, #line, "- <# 주석 #>")

        InAppService.shared.finalizeIAP() // 리무브
    }
    
}
