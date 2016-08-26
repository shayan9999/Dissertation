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
        self.title = "Steps Per Day"
        super.viewDidLoad()
        self.initializeGraphView()
        self.loadGraphViewData()
    }
    
    @IBAction func toggleCriticalData(sender: AnyObject) {
        
        if !isShowingCriticalData{

            graphView.barLineColor = UIColor.colorFromHex("#232323")
            graphView.barColor = UIColor.colorFromHex("#232323")
            graphView.backgroundFillColor = UIColor.colorFromHex("#333333")
            graphView.referenceLineLabelColor = UIColor.redColor()
            
            //self.graphView.setData(self.criticalValues, withLabels: self.criticalLabels)
            isShowingCriticalData = true;
        }else{
            graphView.barLineColor = UIColor.colorFromHex("#777777")
            graphView.barColor = UIColor.colorFromHex("#555555")
            graphView.backgroundFillColor = UIColor.colorFromHex("#333333")
            graphView.referenceLineLabelColor = UIColor.whiteColor()
            
            self.graphView.setData(self.values, withLabels: self.labels)
            isShowingCriticalData = false;
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
    
    func initializeGraphView(){
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.EaseOut
        graphView.animationDuration = 1.5
        //graphView.rangeMax = 50
        //graphView.shouldRangeAlwaysStartAtZero = true
        
        graphView.topMargin = 100
        graphView.rightmostPointPadding = 30
        graphView.leftmostPointPadding  = 30
        
        //self.graphViewParent.addSubview(graphView)
    }
    
    func loadGraphViewData(){
        SVProgressHUD.showWithStatus("Loading...");
        self.graphView.setData([1,2,3,4,5,6], withLabels: ["", "", "", "", "", ""])
        
        SKDBManager.sharedInstance.getPatientStepsCountData { (stepsRetrieved) in
            // Setting data and labels now
            SVProgressHUD.dismiss()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            
            for stepsData in stepsRetrieved{
                self.values.append(Double(stepsData.total!))
                self.labels.append(dateFormatter.stringFromDate(stepsData.day!))
                
                if stepsData.total < 50 {
                    self.criticalValues.append(Double(stepsData.total!))
                    self.criticalLabels.append(dateFormatter.stringFromDate(stepsData.day!))
                }
            }
            self.isShowingCriticalData = false
            self.graphView.setData(self.values, withLabels: self.labels)
        }
    }
    
    
}
