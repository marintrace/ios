//
//  AppDelegate.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import Firebase
import Auth0
import SVProgressHUD
import SwaggerClient

let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    //for centering spinner
    //https://github.com/SVProgressHUD/SVProgressHUD/issues/1002#issuecomment-589752702
    static var standard: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //config firebase
        FirebaseApp.configure()
        
        //register default value for user defaults if user hasnt selected otherwise
        UserDefaults.standard.register(defaults: ["asked_for_notification": false])
        
        //set delegate
        UNUserNotificationCenter.current().delegate = self
        
        //setup spinner
        SVProgressHUD.setDefaultMaskType(.clear) //block user interaction
        SVProgressHUD.setDefaultStyle(.dark) //dark coloring
        
        //set api endpoint
        SwaggerClientAPI.basePath = "https://api.marintracingapp.org"
        
        DataService.logMessage(message: "launched")
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        DataService.logMessage(message: "entered foreground")
    }
    
    //MARK: Handle Google OAuth
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            DataService.logMessage(message: "opened url")
            return Auth0.resumeAuth(url, options: options)
    }
    
    //MARK: Notification Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler([.alert])
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

