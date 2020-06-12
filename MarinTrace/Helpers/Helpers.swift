//
//  Helpers.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import UserNotifications

//MARK: Structs

struct AlertHelperFunctions {
    
    //function for presenting a simple error from app delegate
    static func presentErrorAlertOnWindow(title: String, message: String, window: UIWindow) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        window.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //function for presenting a simple error from a view controller
    static func presentAlertOnVC(title: String, message: String, vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
       vc.present(alertController, animated: true, completion: nil)
    }
    
}

struct NotificationScheduler {
    
    static func scheduleNotifications() {
        
        //clear any prexisting notifications and setup notification center
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        //setup location to be ma or branson
        var location = CLLocationCoordinate2D()
        if User.school == .MA {
            location = CLLocationCoordinate2D(latitude: 37.9752352, longitude: -122.5353663)
        } else {
            location = CLLocationCoordinate2D(latitude: 37.9657723, longitude: -122.565353)
        }
        
        //ARRIVAL NOTIFICATION
        //set title and body
        let arrivalContent = UNMutableNotificationContent()
        arrivalContent.title = "Report your symptoms!"
        arrivalContent.body = "Remember to report your symptoms."
        
        //create 250m radius from school notifying on entry
        let arrivalLocation = CLCircularRegion(center: location, radius: 250, identifier: "arrival")
        arrivalLocation.notifyOnEntry = true
        arrivalLocation.notifyOnExit = false
        
        //repeat notification
        let arrivalTrigger = UNLocationNotificationTrigger(region: arrivalLocation, repeats: false)
        
        //create request
        let arrivalRequest = UNNotificationRequest(identifier: "arrival", content: arrivalContent, trigger: arrivalTrigger)
        
        //schedule notification
        center.add(arrivalRequest) { (error) in
            print(error)
        }
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
            }
        })
        
        //DEPARTURE NOTIFICATION
        //set title and body
        let departureContent = UNMutableNotificationContent()
        departureContent.title = "Report your contacts!"
        departureContent.body = "Remember to report your contacts."
        
        //create 250m radius from school notifying on exit
        let departureLocation = CLCircularRegion(center: location, radius: 250, identifier: "exit")
        departureLocation.notifyOnEntry = false
        departureLocation.notifyOnExit = true
        
        //repeat notification
        let departureTrigger = UNLocationNotificationTrigger(region: departureLocation, repeats: false)
        
        //create request
        let departureRequest = UNNotificationRequest(identifier: "departure", content: departureContent, trigger: departureTrigger)
        
        //schedule notification
        center.add(departureRequest)
        
    }
    
    
}

struct Colors {
    
    //school colors
    static func colorFor(forSchool school:User.School) -> UIColor {
        if school == .MA {
            return UIColor(hexString: "#BE2828")
        } else {
            return UIColor(hexString: "#017BD6")
        }
    }
    
}

struct FontHelper {
    
    //modified from https://stackoverflow.com/a/58123083/4777497
    static func roundedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        // Will be SF Compact or standard SF in case of failure.
        let fontSize = size
        if let descriptor = UIFont.systemFont(ofSize: fontSize, weight: weight).fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: fontSize)
        } else {
            return UIFont.preferredFont(forTextStyle: .subheadline)
        }
    }
    
}

//MARK: Extensions

//remove duplicates
//https://stackoverflow.com/a/25739498/4777497
extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

//show/hide spinner
var vSpinner: UIView?

extension UIViewController {
    func showSpinner(onView: UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        //spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        ai.color = .gray
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

//rounding certain corners
//https://stackoverflow.com/a/41197790/4777497
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
