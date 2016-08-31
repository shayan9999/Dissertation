//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

class LandingPageViewController: UIViewController, ProximityContentManagerDelegate, ESTBeaconManagerDelegate {

    
    static weak var sharedInstance: LandingPageViewController!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()

        self.activityIndicator.startAnimating()
        self.prepareBeaconManager()
        self.prepareTempBeacons()
        
        // This will initialize and fetch data from HealthKit
        SKDBManager.sharedInstance.syncCloudDataForStepsCount()
        SKDBManager.sharedInstance.syncCloudDataForBloodPressure()
        
        
        for beaconID: BeaconID in self.allBeacons! {
            beaconManager!.startMonitoringForRegion(beaconID.asBeaconRegion)
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
        
        /*  Setup navigation bar
         
         / BAR SHADOW APPEARANCE ////
         NSShadow* shadow = [NSShadow new];
         shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
         shadow.shadowColor = [UIColor clearColor];
         
         /* BAR TITLE APPEARANCE */
         [[UINavigationBar appearance] setTitleTextAttributes: @{
         NSForegroundColorAttributeName: UIColorFromRGB(0x0187A7),
         NSFontAttributeName: [UIFont fontWithName:@"Panton-ExtraBold" size: 17.0f],
         NSShadowAttributeName: shadow
         }];
         /* BAR TINT COLOR */
         [[UINavigationBar appearance] setBarTintColor: UIColorFromRGB(0xFFFFFF)];
         
         /* BAR BUTTONS APPEARANCE */
         NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
         [UIFont fontWithName:@"TitilliumWeb-Regular" size: 17.0f], NSFontAttributeName, UIColorFromRGB(0x6AA2BB), NSForegroundColorAttributeName,
         nil];
         [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes
         forState:UIControlStateNormal];
         
         [self.navigationItem setHidesBackButton: YES animated:NO];
         
         
         */
    }
    
    //MARK: Delegate Methods
    
    func proximityContentManager(proximityContentManager: ProximityContentManager, didUpdateContent content: AnyObject?) {
        self.activityIndicator!.stopAnimating()
        self.activityIndicator!.removeFromSuperview()

        if let beaconDetails = content as? BeaconDetails {
            self.view.backgroundColor = beaconDetails.backgroundColor
            self.label.text = "You're in \(beaconDetails.beaconName)'s range!"
            self.image.hidden = false
        } else {
            self.view.backgroundColor = BeaconDetails.neutralColor
            self.label.text = "No beacons in range."
            self.image.hidden = true
        }
    
    }
    
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
    
    func prepareTempBeacons(){
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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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

}
