//
//  AppDelegate.swift
//  Culturist
//
//  Created by Peiyun on 2023/9/14.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var lastCacheClearTime: Date?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // set Firebase
        FirebaseApp.configure()
        
        // set navigationBarAppearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = .GR4
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        checkCacheClear()
        
        return true
    }

    func checkCacheClear() {
        // Check if we need to clear the cache
        if let lastClearTime = UserDefaults.standard.object(forKey: "lastCacheClearTime") as? Date {
            let currentTime = Date()
            let timeIntervalSinceLastClear = currentTime.timeIntervalSince(lastClearTime)
            print("Last clear time: \(lastClearTime)")
            print("Current time: \(currentTime)")
            print("Time interval since last clear: \(timeIntervalSinceLastClear)")
            let oneDayInSeconds: TimeInterval = 24 * 60 * 60
            if timeIntervalSinceLastClear >= oneDayInSeconds {
                clearCache()
                // reset the clear time
                lastCacheClearTime = Date()
                UserDefaults.standard.set(lastCacheClearTime, forKey: "lastCacheClearTime")
            }
        } else {
            lastCacheClearTime = Date()
            UserDefaults.standard.set(lastCacheClearTime, forKey: "lastCacheClearTime")
            print("first save: \(String(describing: lastCacheClearTime))")
        }
    }

    // Method to clear the cache
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        print("clearCache")
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
