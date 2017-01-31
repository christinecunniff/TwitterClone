import UIKit

class RegistrationVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerTapped(_ sender: Any) {
        if usernameField.text!.isEmpty || passwordField.text!.isEmpty || emailField.text!.isEmpty || firstNameField.text!.isEmpty || lastNameField.text!.isEmpty {
            // red placeholders
            usernameField.attributedPlaceholder = NSAttributedString(string: "Enter a username", attributes: [NSForegroundColorAttributeName: UIColor.red])
            passwordField.attributedPlaceholder = NSAttributedString(string: "Enter a password", attributes: [NSForegroundColorAttributeName: UIColor.red])
            emailField.attributedPlaceholder = NSAttributedString(string: "Enter an email", attributes: [NSForegroundColorAttributeName: UIColor.red])
            firstNameField.attributedPlaceholder = NSAttributedString(string: "Enter a first name", attributes: [NSForegroundColorAttributeName: UIColor.red])
            lastNameField.attributedPlaceholder = NSAttributedString(string: "Enter a last name", attributes: [NSForegroundColorAttributeName: UIColor.red])
        } else {
            // create new user in MySQL
        }
    }
   
    @IBAction func signInTapped(_ sender: Any) {
    }
    

}

