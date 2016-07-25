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
        
        super.viewDidLoad()

        self.activityIndicator.startAnimating()
        
        self.prepareBeaconManager()
        self.prepareTempBeacons()
        
        
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
        let notification = UILocalNotification()
        var i = 0;
        for beaconID in self.allBeacons! {
            i = i+1
            if beaconID.asBeaconRegion.minor!.isEqualToNumber(region.minor!){
                notification.alertBody = "ENTER region: Beacon" + String(i)
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            }
            
        }
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        let notification = UILocalNotification()
        var i = 0;
        for beaconID in self.allBeacons! {
            i = i+1
            if beaconID.asBeaconRegion.minor!.isEqualToNumber(region.minor!){
                notification.alertBody = "EXIT region: Beacon" + String(i)
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            }
            
        }
    }
    
    //MARK: Utility Functions
    
    func prepareTempBeacons(){
        //allBeacons = NSMutableArray(capacity: 3);
        let beacon1: BeaconID = BeaconID(proximityUUID: DefinitionsConversion.getProximityUUID(), major:52022, minor:44312)
        let beacon2: BeaconID = BeaconID(proximityUUID: DefinitionsConversion.getProximityUUID(), major:50817, minor:7851)
        let beacon3: BeaconID = BeaconID(proximityUUID: DefinitionsConversion.getProximityUUID(), major:16286, minor:62081)
        
        allBeacons = [BeaconID]()
        allBeacons!.append(beacon1)
        allBeacons!.append(beacon2)
        allBeacons!.append(beacon3)
        
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
    
    @IBAction func showHomeKitInterface(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "HomeKit", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.presentViewController(vc!, animated: true, completion: nil)
    }

}
