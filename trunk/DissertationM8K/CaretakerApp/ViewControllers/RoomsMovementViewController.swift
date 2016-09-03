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
    @IBOutlet weak var textViewForRatios: UITextView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let timeFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Movement"
        
        // Setting up DataPicker maximum date value and events
        datePicker.maximumDate = NSDate.init()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        
        // Setting up TimeLineView Points and colors
        timelineView.layer.cornerRadius = 7.0
        self.timelineView.titleColor =  UIColor.blackColor()
        self.timelineView.bubbleColor = DefinitionsConversion.getYellowColorForTexts()
        self.timelineView.descriptionColor  = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        segmentControl.selectedSegmentIndex = 0
        self.showTimeLine()
        self.reloadRoomMovementData()
    }
    
    //MARK: Helper Functions
    
    func reloadRoomMovementData(){
        
        SVProgressHUD.showWithStatus("Loading...")
        self.textViewForRatios.text = ""
        
        SKDBManager.sharedInstance.getPatientRoomMovementDataForDate(datePicker.date){ returnedArray in
            
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateStyle = .NoStyle
            timeFormatter.timeStyle = .ShortStyle
            
            dispatch_async(dispatch_get_main_queue(), {

                if let roomDataArray = returnedArray{
                    
                    self.timelineView.points = []
                    
                    // If we have at least some room movement data
                    if(roomDataArray.count > 0){
                        
                        var timePerRoom = [String: Int?]()
                        
                        // Go through data from each day and populate timeline view and ratios textView
                        for roomData in roomDataArray{
                            self.timelineView.points.append(
                                ISPoint(  title: timeFormatter.stringFromDate(roomData.start_time!),
                                    description: roomData.name!,
                                     pointColor: UIColor.greenColor(),
                                      lineColor: UIColor.blackColor(),
                                  touchUpInside: nil,
                                           fill: false))
                            
                            if let oldMinutes = timePerRoom[roomData.name!] {
                                let timeDifference: Int? = roomData.end_time?.timeIntervalSinceDate(roomData.start_time!).totalMinutes
                                timePerRoom[roomData.name!] = oldMinutes! + (timeDifference ?? 0)
                            }else{
                                timePerRoom[roomData.name!] = roomData.end_time?.timeIntervalSinceDate(roomData.start_time!).totalMinutes
                            }
                            
                        }
                        
                        for roomName in timePerRoom.keys{
                            let timeInRoom = NSString.localizedStringWithFormat("%@ : \n     %ld minutes\n", roomName, (timePerRoom[roomName])!!)
                            self.textViewForRatios.insertText(timeInRoom as String)
                            self.textViewForRatios.insertText("----------------\n")
                        }
                        
                        SVProgressHUD.dismiss()
                        
                        
                        
                    // Otherwise show error message in place of description in timeline view
                    }else{
                        self.timelineView.points.append(
                            ISPoint(  title: timeFormatter.stringFromDate(NSCalendar.currentCalendar().startOfDayForDate(self.datePicker.date)),
                                description: "Sorry, we don't have movement information for this day",
                                pointColor: UIColor.greenColor(),
                                lineColor: UIColor.blackColor(),
                                touchUpInside: nil,
                                fill: false))
                        
                        self.textViewForRatios.insertText("Sorry, we don't have movement information for this day")
                        
                        SVProgressHUD.dismiss()
                    }
                    
                    
                }   
                
            });
            
        }
        
    }
    
    func showTimeLine(){
        self.timelineView.hidden = false;
        self.textViewForRatios.hidden = true;
    }
    
    func showRatios(){
        self.timelineView.hidden = true;
        self.textViewForRatios.hidden = false;
    }
    
    //MARK: UI Interactions
    
    func datePickerValueChanged(){
        SVProgressHUD .showWithStatus("Retreiving Data...")
        self.reloadRoomMovementData()
    }
    
    @IBAction func switchControlValueChanged (sender: AnyObject) {
        let switchControl = sender as! UISegmentedControl
        
        let selectedIndex = switchControl.selectedSegmentIndex
        
        switch selectedIndex {
            case 0: self.showTimeLine(); break;
            case 1: self.showRatios(); break;
            default: break;
        }
        
    }
    
    
}