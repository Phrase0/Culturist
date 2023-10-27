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
    var cacheClearTimer: Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
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
        // Set up the timer to clear the cache when the application launches
        startCacheClearTimer()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Stop the timer when the application is about to terminate
        stopCacheClearTimer()
    }
    
    // Start the timer
    func startCacheClearTimer() {
        let oneDayInSeconds: TimeInterval = 24 * 60 * 60
        cacheClearTimer = Timer.scheduledTimer(timeInterval: oneDayInSeconds, target: self, selector: #selector(clearCache), userInfo: nil, repeats: true)
        print("clean cache")
    }
    
    // Method to clear the cache
    @objc func clearCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    // Stop the timer
    func stopCacheClearTimer() {
        cacheClearTimer?.invalidate()
        cacheClearTimer = nil
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
