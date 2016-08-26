//
//  NavigationUtility.swift
//  DissertationM8K
//
//  Created by Shayan K. on 7/25/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import UIKit

class SKNavigationUtility: NSObject {
    
    #if PATIENTAPP
    
    static func closeHomeKitSection(){
        LandingPageViewController.sharedInstance!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    #endif

}
