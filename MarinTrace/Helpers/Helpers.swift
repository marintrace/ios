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
import SVProgressHUD
import SafariServices
import SwaggerClient
import Auth0

//MARK: Structs

struct AlertHelperFunctions {
    
    //function for presenting a simple error from app delegate
    static func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            AppDelegate.standard.window!.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func dismissAnyAlertControllerIfPresent(completion: @escaping() -> Void) {
        guard var topVC = AppDelegate.standard.window!.rootViewController?.presentedViewController else {return}
        while topVC.presentedViewController != nil  {
            topVC = topVC.presentedViewController!
        }
        if topVC.isKind(of: UIAlertController.self) {
            topVC.dismiss(animated: false) {
                completion()
            }
        }
    }
    
}

struct NotificationScheduler {
    static func scheduleNotifications() {
        //clear any prexisting symptom notifications and setup notification center
        clearNotifications(for: "symptom")
                
        //schedule
        createNotifications(for: "symptom", title: "Report your symptoms!", body: "Remember to report your symptoms.", hour: 8)
    }
    
    static func scheduleTracingNotifications() {
        //clear any prexisting tracing notifications
        clearNotifications(for: "contact")
        
        //schedule
        createNotifications(for: "contact", title: "Log your contacts!", body: "Remember to log your contacts today outside your cohort.", hour: 17)
    }
    
    /// We want notifications for every day, but we also need to be able to cancel today's notification if they fill out their symptoms. This can't be done with a repeating calendar trigger, so we have to create a bunch manually and then remove one via its id. We distinguish contact/symptom notifications by an id prefix.
    /// - Parameters:
    ///   - type: symptom or contact
    ///   - title: notification title
    ///   - body: notification body
    ///   - hour: hour to send notification each day
    static func createNotifications(for type: String, title: String, body: String, hour: Int) {
        let center = UNUserNotificationCenter.current()
        
        //30 days worth of notifcations
        for i in 1...30 {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            
            //get day n
            let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) //set time to zero so we don't accidentally miss tomorrow if its already passed that time today
            let day = Calendar.current.date(byAdding: .day, value: i, to: today!)
            
            //don't send on weekend
            if !Calendar.current.isDateInWeekend(day!) {
                var components = Calendar.current.dateComponents([.day, .month, .year, .hour, .month], from: day!)
                components.hour = hour
                components.minute = 0
                components.second = 0
                                        
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                //create request with id of date in ISO-8601
                let symptomsRequest = UNNotificationRequest(identifier: "\(type)-\(DateHelper.stringFromDate(withFormat: "yyyy-MM-dd", date: day!))", content: content, trigger: trigger)
                
                //schedule notification
                center.add(symptomsRequest)
            }
        }
        
        //debug
        /*center.getPendingNotificationRequests { (requests) in
            print(requests.map({($0.identifier, $0.content.body, $0.content.title, $0.trigger)}))
        }*/
    }
    
    /// Remove notifications so we can recreate after today's
    /// - Parameter type: symptom or contact
    static func clearNotifications(for type: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (requests) in
            let filtered = requests.filter({$0.identifier.contains(type)}).map({$0.identifier})
            center.removePendingNotificationRequests(withIdentifiers: filtered)
        }
    }
    
    /*static func scheduleTestNotifications() {
        
        //clear any prexisting notifications and setup notification center
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
                
        //we want notifications for every day, but we also need to be able to cancel today's notification if they fill out their symptoms. This can't be done with a repeating calendar trigger, so we have to create a bunch manually starting tomorrow. If they report symptoms before the notification sends tomorrow, then all these will be cleared, and a new set starting the next day will be created.
        
        //30 days worth of notifcations
        for i in 1...30 {
            let symptomsContent = UNMutableNotificationContent()
            symptomsContent.title = "Report your symptoms!"
            symptomsContent.body = "Remember to report your symptoms."
            
            //get day n
            let day = Calendar.current.date(byAdding: .minute, value: i, to: Date())
            
            var components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: day!)
            components.second = 0
            
            let symptomsTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            //create request with id of date in ISO-8601
            let symptomsRequest = UNNotificationRequest(identifier: UUID().uuidString, content: symptomsContent, trigger: symptomsTrigger)
            
            //schedule notification
            center.add(symptomsRequest) { (error) in
                print(error)
            }
            
        }
        
    }*/
}

struct DateHelper {
    static func stringFromDate(withFormat format:String, date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let string = formatter.string(from: date)
        return string
    }
    
    static func dateFromString(withFormat format: String, string:String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let date = formatter.date(from: string)
        return date!
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

//use helper functions so we don't need to import on every file
struct SpinnerHelper {
    static func show() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
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

//get more detailed swagger error, if failure just use description
extension Error {
    var swaggerError: String {
        guard let errorResponse = self as? ErrorResponse else {
            guard let authError = self as? CredentialsManagerError else {
                return self.localizedDescription
            }
            return (authError as NSError).description
        }
        if let cleanError = DataService.getAPIError(response: errorResponse), !cleanError.isEmpty {
            return cleanError
        } else {
            return self.localizedDescription
        }
    }
}


//https://stackoverflow.com/a/41197790/4777497
//rounding certain corners
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

extension UIViewController {
    func showSafariViewController(url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            self.present(vc, animated: true)
        }
    }
}

extension Collection where Iterator.Element == String {
    func joinedWithComma() -> String {
        var string = joined(separator: ", ")

        if let lastCommaRange = string.range(of: ", ", options: .backwards) {
            string.replaceSubrange(lastCommaRange, with: " and ")
        }

        return string
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

//date stuff for testing
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

