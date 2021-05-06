//
//  SchoolConfig.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 5/6/21.
//  Copyright © 2021 Marin Trace. All rights reserved.
//

import UIKit

//School by school configuration
struct Colors {
    //school colors
    static func colorFor(forSchool school:User.School) -> UIColor {
        switch User.school{
        case .MA:
            return UIColor(hexString: "#BE2828")
        case .Branson:
            return UIColor(hexString: "#017BD6")
        case .Headlands:
            //return UIColor(hexString: "#14422b") alternate green color
            return UIColor(hexString: "#dc5a33")
        case .TildenAlbany, .TildenWalnutCreek:
            return UIColor(hexString: "#347ce1")
        }
    }
    
    static var greenColor = UIColor(hexString: "#27ae60")
    static var redColor = UIColor(hexString: "#c0392b")
    static var yellowColor = UIColor(hexString: "#f1c40f")
    static var greyColor = UIColor(hexString: "#7f8c8d")
}

struct Titles {
    //school home page colors
    static func titleFor(forSchool school:User.School) -> String {
        switch User.school {
        case .MA:
            return "MA Trace"
        case .Branson:
           return "Branson Trace"
        case .Headlands:
            return "Headlands Prep"
        case .TildenAlbany:
            return "Tilden (Albany)"
        case .TildenWalnutCreek:
            return "Tilden (Walnut Creek)"
        }
    }
}

struct ProfileImages {
    //school images
    static func imageFor(forSchool school:User.School) -> UIImage {
        switch User.school{
        case .MA:
            return UIImage(named: "profile_ma")!.withRenderingMode(.alwaysOriginal)
        case .Branson:
            return UIImage(named: "profile_branson")!.withRenderingMode(.alwaysOriginal)
        case .Headlands:
            return UIImage(named: "profile_headlands")!.withRenderingMode(.alwaysOriginal)
        case .TildenAlbany, .TildenWalnutCreek:
            return UIImage(named: "profile_tilden")!.withRenderingMode(.alwaysOriginal)
        }
    }
}

struct SectionVisibility{
    static func showSection(forSchool school:User.School, section: Int) -> Bool {
        switch User.school {
        case .MA:
            switch section {
            //case 0, 1, 2, 3: return true
            default: return false //hide nothing
            }
        case .Branson:
            switch section {
            case 2: return true //hide testing
            default: return false
            }
        case .Headlands:
            switch section {
            case 2: return true //hide testing
            default: return false
            }
        case .TildenAlbany:
            switch section {
            default: return false //hide nothing
            }
        case .TildenWalnutCreek:
            switch section {
            default: return false //hide nothing
            }
        }
    }
}
