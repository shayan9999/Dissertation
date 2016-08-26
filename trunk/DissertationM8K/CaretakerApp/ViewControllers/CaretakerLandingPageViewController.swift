//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

class CaretakerLandingPageViewController: UIViewController {
    
    @IBOutlet weak var buttonForRoomMovement: UIButton!
    @IBOutlet weak var buttonForHealthAndActivity: UIButton!
    
    override func viewDidLoad() {
        // Setting up navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        
        super.viewDidLoad()
        
        // Applying round shape on all buttons
        buttonForRoomMovement.layer.cornerRadius = 8.0
        buttonForHealthAndActivity.layer.cornerRadius = 8.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
