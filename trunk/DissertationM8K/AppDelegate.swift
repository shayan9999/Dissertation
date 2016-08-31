//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit
import CloudKit
import SVProgressHUD

//#import <AWSCognito/AWSCognito.h>

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.initalizeExternalPlugins()
        self.initializeNotificationsSettings()
        
        if((launchOptions?[UIApplicationLaunchOptionsLocationKey]) != nil){
            NSLog("### Opened App through Location Notification")
        }else if((launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]) != nil){
            self.resetBadgeCount()
            NSLog("### Opened App through Remote Notification")
        }

        return true
    }
    
    //MARK: - Application Global Setup
    
    func initalizeExternalPlugins(){
        
        // Setting up Estimote
        ESTConfig.setupAppID("dissertation-m8k", andAppToken: "59d81ff17324db3d77d9d4f0e7ad3b12")
        
        SVProgressHUD.setDefaultMaskType( SVProgressHUDMaskType.Gradient)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
    }
    
    func initializeNotificationsSettings(){
        
        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
            if(UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))){
                let settingsForNotification = UIUserNotificationSettings.init(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settingsForNotification)
                UIApplication.sharedApplication().registerForRemoteNotifications()
            }
        }
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)
    }
    
    func resetBadgeCount(){
        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        CKContainer.defaultContainer().addOperation(badgeResetOperation)
    }
    
    
    //MARK: - Notifications Handlers
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        print("### Remote Notifications Registration Successful")
        
        #if PATIENTAPP
            //SKDBManager.sharedInstance.removeAllCloudKitSubscriptions()
            SKDBManager.sharedInstance.setupCloudKitSubscriptions()
        #endif
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        print("### Local Notifications Registration Successful")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("### Received Local Notification")
    }
    
    // Called when remote notification will trigger a background fetch routine
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        #if PATIENTAPP
        
            let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: (userInfo as! [String: NSObject]))
            
            // This will execute when one of the CloudKit subscriptions was triggered.
            if cloudKitNotification.notificationType == CKNotificationType.Query {

                //let queryNotification = cloudKitNotification as! CKQueryNotification
                //let recordID = queryNotification.recordID
                
                self.resetBadgeCount()
                print("Notification: " + userInfo.description)
                SKNotificationsUtility.syncNotificationsForEncouragements()
            }
            
        #endif
        
        completionHandler(.NewData);
    }
    
    //MARK: - Background Fetch Operations
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        #if PATIENTAPP
            
            SKDBManager.sharedInstance.syncCloudDataForStepsCount()
            SKDBManager.sharedInstance.syncCloudDataForBloodPressure()
            
            let localNotification = UILocalNotification()
            localNotification.alertBody = "Just downloaded something in background"
            application.presentLocalNotificationNow(localNotification)
            
        #endif
        
        completionHandler(.NewData)
    }
    
    
    //MARK: - Application Lifecycle Handlers

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
