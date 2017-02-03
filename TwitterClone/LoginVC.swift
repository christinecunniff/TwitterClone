import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginTapped(_ sender: UIButton) {
        
        if usernameField.text!.isEmpty || passwordField.text!.isEmpty {
            usernameField.attributedPlaceholder = NSAttributedString(string: "Enter username", attributes: [NSForegroundColorAttributeName: UIColor.red])
            passwordField.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSForegroundColorAttributeName: UIColor.red])
        } else {
            // send request to mysql db
        }
        
    }

}
