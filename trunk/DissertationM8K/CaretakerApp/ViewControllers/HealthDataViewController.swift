//
//  HealthDataViewController.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/25/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation
import ScrollableGraphView
import SVProgressHUD
import DOAlertController.Swift

class HealthDataViewController : UIViewController {
    
    
    @IBOutlet weak var graphView: ScrollableGraphView!
    @IBOutlet weak var graphViewParent: UIView!
    
    var isShowingCriticalData = false;
    var values = [Double]();
    var criticalValues = [Double]()
    var labels = [String]()
    var criticalLabels = [String]()
    
    //var graphView: ScrollableGraphView!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewDidLoad()
        self.initializeGraphView()
        self.loadGraphViewData()
    }
    
    //MARK: UI Interactions
    
    @IBAction func toggleCriticalData(sender: AnyObject) {
        
        let button = sender as! UIButton;
        
        if(self.criticalLabels.count <= 0){
            
            let alertController = SKNotificationsUtility.getSingleButtonAlertView(withTitle: "No Data", andMessage: "There is no critical data in the current set")
            self.presentViewController(alertController, animated: true, completion: nil)
            return;
        }
        
        if !isShowingCriticalData{
            
            graphView.shouldAnimateOnStartup = true
            graphView.barLineColor = UIColor.colorFromHex("#232323")
            graphView.barColor = UIColor.redColor()
            graphView.backgroundFillColor = UIColor.colorFromHex("#333333")
            graphView.referenceLineLabelColor = UIColor.whiteColor()
            
            //self.graphView.setData([1,2,3,4,5,6], withLabels: ["", "", "", "", "", ""])
            button.setTitle("Show All", forState: UIControlState.Normal)
            self.graphView.setData(self.criticalValues, withLabels: self.criticalLabels)
            isShowingCriticalData = true;
        }else{
            graphView.shouldAnimateOnStartup = true
            graphView.barLineColor = UIColor.colorFromHex("#777777")
            graphView.barColor = UIColor.colorFromHex("#555555")
            graphView.backgroundFillColor = UIColor.colorFromHex("#333333")
            graphView.referenceLineLabelColor = UIColor.whiteColor()
            
            self.graphView.setData(self.values, withLabels: self.labels)
            button.setTitle("Critical", forState: UIControlState.Normal)
            isShowingCriticalData = false;
        }
        
    }
    
    @IBAction func switchControlValueChanged (sender: AnyObject) {
        let switchControl = sender as! UISegmentedControl
        
        let selectedIndex = switchControl.selectedSegmentIndex
        
        self.values.removeAll()
        self.labels.removeAll()

        self.criticalValues.removeAll()
        self.criticalLabels.removeAll()
        
        switch selectedIndex {
            case 0: self.showStepsDataOnGraph(); break;
            case 1: self.showBloodPressureDataOnGraph(); break;
            default: break;
        }
        
    }
        
        
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        // A solution to disable vertical scrolling on the graph
        //graphView.contentSize = CGSizeMake(graphView.contentSize.width, graphViewParent.frame.height);
        //graphView.setContentOffset(CGPointMake(0, 0), animated: false);
        //self.automaticallyAdjustsScrollViewInsets = false;
        
        //self.loadGraphViewData()
    }
    
    //MARK: View Helpers
    
    func initializeGraphView(){
        
        graphView.shouldAnimateOnStartup = false
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.EaseOut
        graphView.animationDuration = 0.4
        //graphView.rangeMax = 50
        //graphView.shouldRangeAlwaysStartAtZero = true
        
        graphView.topMargin = 100
        graphView.rightmostPointPadding = 30
        graphView.leftmostPointPadding  = 30
        
        //self.graphViewParent.addSubview(graphView)
    }
    
    func loadGraphViewData(){
        
        self.graphView.setData([1000,2000,3999, 4999, 5000, 4000], withLabels: ["Date", "Date", "Date", "Date", "Date", "Date"])
        
        self.showStepsDataOnGraph()
    }
    
    func showStepsDataOnGraph(){
        
        self.navigationItem.title = "Steps Per Day"
        SVProgressHUD.showWithStatus("Loading...");
        
        SKDBManager.sharedInstance.getPatientStepsCountData { (stepsRetrieved) in
            // Setting data and labels now
            SVProgressHUD.dismiss()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            
            for stepsData in stepsRetrieved{
                self.values.append(Double(stepsData.total!))
                self.labels.append(dateFormatter.stringFromDate(stepsData.day!))
                
                if stepsData.total! <= SKConstants.getCriticalStepsCount() {
                    self.criticalValues.append(Double(stepsData.total!))
                    self.criticalLabels.append(dateFormatter.stringFromDate(stepsData.day!))
                }
                
            }
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.isShowingCriticalData = false
                self.graphView.setData(self.values, withLabels: self.labels)
            }
        }
    }
    
    func showBloodPressureDataOnGraph(){
        
        self.navigationItem.title = "Blood Pressure per Day"
        SVProgressHUD.showWithStatus("Loading...");
        
        SKDBManager.sharedInstance.getPatientBloodPressureData { (bpInfoReceived) in
            // Setting data and labels now
            SVProgressHUD.dismiss()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            
            for bpData in bpInfoReceived{
                self.values.append(Double(bpData.total!))
                self.labels.append(dateFormatter.stringFromDate(bpData.day!))
                
                if bpData.total! <= SKConstants.getCriticalBloodPressure() {
                    self.criticalValues.append(Double(bpData.total!))
                    self.criticalLabels.append(dateFormatter.stringFromDate(bpData.day!))
                }
            }
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.isShowingCriticalData = false
                self.graphView.setData(self.values, withLabels: self.labels)
            }
        }
    }
    
}
