//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit
import CloudKit

//#import <AWSCognito/AWSCognito.h>

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().unregisterForRemoteNotifications();
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
        
        
        // Setting up AWS DynamoDB
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:"us-east-1:e3ab1158-6f5a-4850-98cb-4397a9ce715c")
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
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
        
        //SKDBManager.sharedInstance().removeAllCloudKitSubscriptions()
        SKDBManager.sharedInstance.setupCloudKitSubscriptions()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        print("### Local Notifications Registration Successful")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("### Received Local Notification")
    }
    
    // Called when remote notification will trigger a background fetch routine
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: (userInfo as! [String: NSObject]))
        
        if cloudKitNotification.notificationType == CKNotificationType.Query {
            // TODO: Do something with the information for the new values to be fetched
            // TODO: Also can create notification on the basis of the information fetched
            self.resetBadgeCount()
            print("Notification: " + userInfo.description)
        }
        
        print ("Notification: " + ((cloudKitNotification.alertBody ?? "").isEmpty ? "Default" : cloudKitNotification.alertBody!))
        
        completionHandler(.NewData);
        
    }
    
    //MARK: - Background Fetch Operations
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        SKDBManager.sharedInstance.getAllTiggers()
        completionHandler(.NewData)
        
        let localNotification = UILocalNotification()
        localNotification.alertBody = "Just downloaded something in background"
        application.presentLocalNotificationNow(localNotification)
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
