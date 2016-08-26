//
//  Date.swift
//  Prayerz
//
//  Created by Mazyad Alabduljaleel on 9/16/15.
//  Copyright (c) 2015 ArabianDevs. All rights reserved.
//

import Foundation


/** A date associated with an `NSCalendar` */
public struct DateView {
    
    // MARK: - Properties
    
    public let date: NSDate
    public let calendar: NSCalendar
    
    public var components: CalendarComponents {
        
        return calendar.components(
            NSCalendarUnit(rawValue: UInt.max),
            fromDate: date
        ).calendarComponents
    }
    
    // MARK: - Init & Dealloc
    
    public init(forDate date: NSDate, inCalendar calendar: NSCalendar) {
        
        self.calendar = calendar
        self.date = date
    }
    
    public init(forCalendarComponents calendarComponents: CalendarComponents, inCalendar calendar: NSCalendar) {
        
        self.init(
            forDate: calendar.dateFromComponents(calendarComponents.dateComponents)!,
            inCalendar: calendar
        )
    }
    
    // MARK: - Public methods
    
    public func update(
        year year: Int? = nil,
        month: Int? = nil,
        day: Int? = nil,
        hour: Int? = nil,
        minute: Int? = nil,
        second: Int? = nil
    ) -> DateView
    {
        let comps = components.update(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return DateView(forCalendarComponents: comps, inCalendar: calendar)
    }
}
