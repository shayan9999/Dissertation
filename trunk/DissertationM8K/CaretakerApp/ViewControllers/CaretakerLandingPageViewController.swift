//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

class CaretakerLandingPageViewController: UIViewController {
    
    @IBOutlet var menuButtonsCollection: [UIButton]!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setting up Nav bar and Window defaults
        UINavigationBar.appearance().backgroundColor = UIColor.clearColor()
        UINavigationBar.appearance().tintColor       = UIColor.whiteColor()
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Panton-Regular", size: 19.0)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Panton-Regular", size: 15.0)!], forState: UIControlState.Normal)
        //UIApplication.sharedApplication().keyWindow?.tintColor = UIColor.whiteColor()
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        
        // Applying round shape on all buttons
        for button in menuButtonsCollection{
            button.layer.cornerRadius = 8.0
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
