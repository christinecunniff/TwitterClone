import UIKit

class ResetVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func resetTapped(_ sender: Any) {
        if emailField.text!.isEmpty {
            emailField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName: UIColor.red])
        } else {
            // if text is entered, send mysql/php/hosting request
        }
    }
}
