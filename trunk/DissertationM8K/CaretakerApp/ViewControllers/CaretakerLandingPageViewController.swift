//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

class CaretakerLandingPageViewController: UIViewController {
    
    @IBOutlet var menuButtonsCollection: [UIButton]!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setting up navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        
        // Applying round shape on all buttons
        for button in menuButtonsCollection{
            button.layer.cornerRadius = 8.0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
