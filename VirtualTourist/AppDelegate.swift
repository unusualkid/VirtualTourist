//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 10/28/17.
//  Copyright © 2017 Cotery. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Usually this is not overridden. Using the "did finish launching" method is more typical
        print("App Delegate: will finish launching")
        checkIfFirstLaunch()
        stack.autoSave(5)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("App Delegate: did become active")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        stack.save()
        print("App Delegate: will resign active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        stack.save()
        print("App Delegate: did enter background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        print("App Delegate: will enter foreground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("App Delegate: will terminate")
    }
    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.set(25.0340, forKey: Constants.Map.Key.Latitude)
            UserDefaults.standard.set(121.5645, forKey: Constants.Map.Key.Longitude)
            UserDefaults.standard.synchronize()
        }
        
        UserDefaults.standard.set(true, forKey: Constants.Map.Key.IsFirstLoad)
        print("UserDefaults.standard.bool(forKey: Constants.Map.Key.IsFirstLoad): \(UserDefaults.standard.bool(forKey: Constants.Map.Key.IsFirstLoad)) ")
    }
}
