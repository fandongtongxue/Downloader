//
//  AppDelegate.swift
//  Downloader
//
//  Created by isoftstone on 2023/10/10.
//

import UIKit
import Tiercel

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        let path = Cache.defaultDiskCachePathClosure("Test")
        let cacahe = Cache("ViewController2", downloadPath: path)
        let manager = SessionManager("ViewController2", configuration: configuration, cache: cacahe, operationQueue: DispatchQueue(label: "com.Tiercel.SessionManager.operationQueue"))
        return manager
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if sessionManager.identifier == identifier {
            sessionManager.completionHandler = completionHandler
        }
    }

}

