//
//  RoomMovementViewController.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/15/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import UIKit
import ISTimeline
import SVProgressHUD


class RoomsMovementViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timelineView: ISTimeline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.maximumDate = NSDate.init()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        timelineView.layer.cornerRadius = 7.0
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Movement"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadRoomMovementData()
    }
    
    
    func reloadRoomMovementData(){
        
        SKDBManager.sharedInstance.getRoomMovementDataForDate(datePicker.date){ returnedArray in
            
            // Format time in AM/ PM format
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateStyle = .NoStyle
            timeFormatter.timeStyle = .ShortStyle
            
            SVProgressHUD.dismiss()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.timelineView.points = []
                self.timelineView.titleColor = DefinitionsConversion.getRedColorForTexts()
                self.timelineView.bubbleColor = DefinitionsConversion.getYellowColorForTexts()
                
                if let roomDataArray = returnedArray{
                    
                    if(roomDataArray.count > 0){
                        for object in roomDataArray{
                            let roomData: SKRoomData = object as! SKRoomData
                            self.timelineView.points.append(
                                ISPoint(  title: timeFormatter.stringFromDate(roomData.start_time!),
                                    description: roomData.name!,
                                     pointColor: UIColor.greenColor(),
                                      lineColor: UIColor.blackColor(),
                                  touchUpInside: nil,
                                           fill: false))
                        }
                    }else{
                        self.timelineView.points.append(
                            ISPoint(  title: timeFormatter.stringFromDate(NSCalendar.currentCalendar().startOfDayForDate(self.datePicker.date)),
                                description: "Sorry, we don't have movement information for this day",
                                pointColor: UIColor.greenColor(),
                                lineColor: UIColor.blackColor(),
                                touchUpInside: nil,
                                fill: false))
                    }
                    
                    
                }   
                
            });
            
        }
        
    }
    
    func datePickerValueChanged(){
        SVProgressHUD .showWithStatus("Retreiving Data...")
        self.reloadRoomMovementData()
    }
    
    
}