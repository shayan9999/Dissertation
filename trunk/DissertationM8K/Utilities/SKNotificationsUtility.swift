//
//  SKNotificationsUtility.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/27/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation

class SKNotificationsUtility: NSObject {
    
    
    static func syncNotificationsForEncouragements(){
        // Get all encouragements data and setup new notifications
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        SKDBManager.sharedInstance.getAllEncouragements({ (encouragementsReceived) in
            for e in encouragementsReceived{
                print("Updated : %@ %d", e.name, e.timing)
                SKNotificationsUtility.setNotifications(forEncouragement: e)
            }
        })
    }
    
    
    static func setNotifications(forEncouragement encouragement: SKEncouragement){
       
        let notification = UILocalNotification()
        
        notification.timeZone = NSCalendar.currentCalendar().timeZone
        notification.alertBody = encouragement.name
        notification.fireDate = encouragement.timeofDay
        
        /* Time and timezone settings */
        if let repeatInterval = SKNotificationsUtility.getRepeatIntervalForTimingOption(encouragement.timing!) {
            notification.repeatInterval = repeatInterval
        }
        
        /* Action settings */
        notification.hasAction = true
        notification.alertAction = "View"
        
        /* Badge settings */
        notification.applicationIconBadgeNumber =
            UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        /* Schedule the notification */
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func getRepeatIntervalForTimingOption( timingOption: SKEncouragementDataTiming) -> NSCalendarUnit?{
        var repeatInterval: NSCalendarUnit? = NSCalendarUnit.Day
        
        switch timingOption {
            case .Once: repeatInterval = nil; break;
            case .EveryDay : repeatInterval = NSCalendarUnit.Day; break;
            case .EveryMonth: repeatInterval = NSCalendarUnit.Month; break;
            case .EveryWeek: repeatInterval = NSCalendarUnit.WeekOfYear; break;
            case .OnWeekdays: repeatInterval = NSCalendarUnit.WeekdayOrdinal; break;
        }
        
        return repeatInterval
    }
    
}