//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

class LandingPageViewController: UIViewController, ESTBeaconManagerDelegate {

    
    static weak var sharedInstance: LandingPageViewController!
    
    //@IBOutlet weak var label: UILabel!
    //@IBOutlet weak var image: UIImageView!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var menuButtonsCollection: [UIButton]!
    
    var proximityContentManager: ProximityContentManager!
    var beaconManager: ESTBeaconManager?
    var allBeacons: [BeaconID]?

    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        
        
        if (LandingPageViewController.sharedInstance == nil){
            LandingPageViewController.sharedInstance = self
        }else{
            assertionFailure()
        }
        
        super.viewDidLoad()
        
        // Setting up navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //self.activityIndicator.startAnimating()
        self.prepareBeaconManager()
        self.prepareRoomBeacons()
        
        // This will initialize and fetch data from HealthKit
        // SKDBManager.sharedInstance.authorizeAndSyncHealthKitData()
        
        
        for beaconID: BeaconID in self.allBeacons! {
            beaconManager!.startMonitoringForRegion(beaconID.asBeaconRegion)
        }
        
        // Applying round shape on all buttons
        for button in menuButtonsCollection{
            button.layer.cornerRadius = 8.0
        }

        /*
        self.proximityContentManager = ProximityContentManager(
            beaconIDs: [
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 52022, minor: 44312),
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 50817, minor: 7851),
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 16286, minor: 62081)
            ],
            beaconContentFactory: CachingContentFactory(beaconContentFactory: BeaconDetailsCloudFactory()))
        self.proximityContentManager.delegate = self
        self.proximityContentManager.startContentUpdates()
         */
    }
    
    //MARK: Delegate Methods
    
//    func proximityContentManager(proximityContentManager: ProximityContentManager, didUpdateContent content: AnyObject?) {
//        self.activityIndicator!.stopAnimating()
//        self.activityIndicator!.removeFromSuperview()
//
//        if let beaconDetails = content as? BeaconDetails {
//            self.view.backgroundColor = beaconDetails.backgroundColor
//            self.label.text = "You're in \(beaconDetails.beaconName)'s range!"
//            self.image.hidden = false
//        } else {
//            self.view.backgroundColor = BeaconDetails.neutralColor
//            self.label.text = "No beacons in range."
//            self.image.hidden = true
//        }
//    
//    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    // This method is called upon entering regions of beacons
    
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        //let notification = UILocalNotification()
        var i = 0;
        for beaconID in self.allBeacons! {
            i = i+1
            if beaconID.asBeaconRegion.minor!.isEqualToNumber(region.minor!){
                
                // Print which beacon's region we are entering
                if let regionName = self.getNameForBeaconMinor(region.minor!){
                    NSLog("Enter region: %@", regionName)
                    
                    let lastKnownBeaconMinor   = NSUserDefaults.standardUserDefaults().integerForKey(SKConstants.UDK_For_CloudKit_Last_Known_Beacon_Minor)
                    
                    if(lastKnownBeaconMinor != region.minor!){
                        NSLog("---- New Room: %@", regionName)
                        
                        // Storing new room information in user defaults
                        NSUserDefaults.standardUserDefaults().setInteger(region.minor!.integerValue, forKey: SKConstants.UDK_For_CloudKit_Last_Known_Beacon_Minor)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        // Storing new room information in iCloud 
                        SKDBManager.sharedInstance.writeNewRoomEntry(regionName, roomStartTime: NSDate.init() )
                    }
                    
                    //if(NSUserDefaults.standardUserDefaults().valueForKey(UDK_For_CloudKit_Last_Known_Beacon_Minor))
                }
                
                //notification.alertBody = "ENTER region: Beacon" + String(i)
                //notification.soundName = UILocalNotificationDefaultSoundName
                //UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            }
            
        }
    }
    
    // Method called upon exiting region
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        //let notification = UILocalNotification()
        var i = 0;
        for beaconID in self.allBeacons! {
            i = i+1
            if beaconID.asBeaconRegion.minor!.isEqualToNumber(region.minor!){
                
                // Print which beacon's region we are exiting
                if let regionName = self.getNameForBeaconMinor(region.minor!){
                    NSLog("EXIT region: %@", regionName)
                }
                
                //notification.alertBody = "EXIT region: Beacon" + String(i)
                //notification.soundName = UILocalNotificationDefaultSoundName
                //UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            }
            
        }
    }
    
    //MARK: Utility Functions
    
    func prepareRoomBeacons(){
        //allBeacons = NSMutableArray(capacity: 3);
        let beacon1: BeaconID = BeaconID(proximityUUID: DefinitionsConversion.getProximityUUID(), major:59901, minor:38842)
        let beacon2: BeaconID = BeaconID(proximityUUID: DefinitionsConversion.getProximityUUID(), major:50817, minor:7851)
        let beacon3: BeaconID = BeaconID(proximityUUID: DefinitionsConversion.getProximityUUID(), major:16286, minor:62081)
        
        allBeacons = [BeaconID]()
        allBeacons!.append(beacon1)
        allBeacons!.append(beacon2)
        allBeacons!.append(beacon3)
        
    }
    
    func getNameForBeaconMinor(beaconMinor: NSNumber) -> NSString?{
        var regionName: NSString?
        
        switch beaconMinor.integerValue {
        case 38842: regionName = "Common Room"
        case 7851:  regionName = "Kitchen"
        case 62081: regionName = "Patio"
        default:
            NSLog("Error! should not try to get name for a minor value that is not in database")
            assertionFailure()
            regionName = nil
        }
        
        return regionName
    }
    
    func prepareBeaconManager(){
        self.beaconManager = ESTBeaconManager();
        self.beaconManager?.delegate = self
        self.beaconManager?.requestAlwaysAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UI Interactions
    
    @IBAction func showHomeKitSettings(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "HomeKit", bundle: nil)
        let vc: TabBarController = storyboard.instantiateInitialViewController() as! TabBarController
        vc.showSettingsTab()
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func showHomeKitControls(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "HomeKit", bundle: nil)
        let vc: TabBarController = storyboard.instantiateInitialViewController() as! TabBarController
        vc.showControlsTab()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func callCareTaker(){
        
        SKDBManager.sharedInstance.getAppSettings { (settingsReceived) in
            let caretakerNumber = settingsReceived?.caretakerContact
            
            if caretakerNumber?.isEmpty == true {
                let alert = SKNotificationsUtility.getSingleButtonAlertView(withTitle: "Caretaker Number not found", andMessage: "Ask your caretaker to set up his/ her contact number in settings on their app")
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let phoneNumberURL = "tel://" + caretakerNumber!
                UIApplication.sharedApplication().openURL(NSURL(string: phoneNumberURL)!)
            }
            
        }
        
    }

}
