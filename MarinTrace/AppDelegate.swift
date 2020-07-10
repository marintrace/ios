//
//  AppDelegate.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //config firebase
        FirebaseApp.configure()
        
        //google auth
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        //register default value for user defaults if user hasnt selected otherwise
        UserDefaults.standard.register(defaults: ["asked_for_notification": false])
        
        //set delegate
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    //MARK: Handle Google OAuth
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        //view to remove spinner from
        let view = UIApplication.shared.windows.first?.rootViewController
        
        if let error = error {
            view?.removeSpinner()
            print(error)
            AlertHelperFunctions.presentErrorAlertOnWindow(title: "Error", message: error.localizedDescription, window: UIApplication.shared.windows.first!)
            DataService.logError(error: error)
            return
        }
        
        //user logged in w google, authenticate w firebase
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        //make sure user is MA or Branson
        guard let userEmail = user?.profile.email else { return }
        if userEmail.contains("ma.org") || userEmail.contains("branson.org") {
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                view?.removeSpinner()
                if let error = error {
                    let authError = error as NSError
                    print(authError)
                    AlertHelperFunctions.presentErrorAlertOnWindow(title: "Error", message: authError.localizedDescription, window: UIApplication.shared.windows.first!)
                    DataService.logError(error: authError)
                } else {
                    //user signed in, go to homes
                    let story = UIStoryboard(name: "Main", bundle: nil)
                    let homeVC = story.instantiateViewController(withIdentifier: "HomeTableViewController") as? UINavigationController
                    homeVC!.modalPresentationStyle = .fullScreen
                    UIApplication.shared.windows.first?.rootViewController = homeVC
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
                return
            }
            
        } else {
            view?.removeSpinner()
            AlertHelperFunctions.presentErrorAlertOnWindow(title: "Error", message: "Your account must be @ma.org or @branson.org. Please try signing in with that.", window: UIApplication.shared.windows.first!)
        }
        
    }
        
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //go to log in
        let story = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = story.instantiateViewController(withIdentifier: "LoginTableViewController") as? UINavigationController
        homeVC!.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController = homeVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
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

