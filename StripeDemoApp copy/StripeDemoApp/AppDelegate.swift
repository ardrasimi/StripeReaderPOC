//
//  AppDelegate.swift
//  StripeDemoApp
//
//  Created by Trenser01 on 03/10/24.
//


import UIKit
import StripeTerminal
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Terminal.setTokenProvider(APIClient.shared)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

let PublishableKey = "pk_test_51Q2Pyb2NkSWy1z8XwPhz78m0BayK2qfJuFE6sTD31Iyu72CPaXNThNEQyjtKG2MRuO8uAPJJlKVPkijIDZ87vFjE007n2RvosK"

let UserSecret = "sk_test_51Q2Pyb2NkSWy1z8XfhWcC9Hnrr9UjR67tBfq0eDcKyowdC2IBVxvwSeenVnx95YlSmft3jeKDOIhtTh927eIPVis00Dl1aDllT"
