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
            usernameField.attributedPlaceholder = NSAttributedString(string: "Enter username", attributes: [NSForegroundColorAttributeName: UIColor.red])
            passwordField.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSForegroundColorAttributeName: UIColor.red])
            emailField.attributedPlaceholder = NSAttributedString(string: "Enter email", attributes: [NSForegroundColorAttributeName: UIColor.red])
            firstNameField.attributedPlaceholder = NSAttributedString(string: "Enter first name", attributes: [NSForegroundColorAttributeName: UIColor.red])
            lastNameField.attributedPlaceholder = NSAttributedString(string: "Enter last name", attributes: [NSForegroundColorAttributeName: UIColor.red])
        } else {
            // create new user in MySQL
            let url = NSURL(string: "http://localhost/TwitterClone/register.php?")!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            let body = "username=\(usernameField.text!)&password=\(passwordField.text!)&email=\(emailField.text!)&fullname=\(firstNameField.text!)%20\(lastNameField.text!)"
            // append body to our request that gonna be sent
            request.httpBody = body.data(using: String.Encoding.utf8)
            
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error == nil {
                    // get main queue in code process to communicate back to UI
                    DispatchQueue.main.async(execute: {
                        do {

                            // get json result
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            
                            // assign json to new variable parseJSON in guarded way
                            guard let parseJSON = json else {
                                print("Error while parsing")
                                return
                            }
                            
                            // get id from parseJSON dictionary
                            let id = parseJSON["id"]
                            
                            // registered successfully
                            if id != nil {
                                // save user information recieved form our host
                                UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                                user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                
                                DispatchQueue.main.async(execute: {
                                    appDelegate.logIn()
                                })
                            } else {
                                DispatchQueue.main.async(execute: {
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: redSmoothColor)
                                })
                            }
                            
                        } catch {
                            DispatchQueue.main.async(execute: {
                                let message = error as! String
                                appDelegate.infoView(message: message, color: redSmoothColor)
                            })
                        }
                    })
                    // if unable to proceed with the request
                } else {
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: redSmoothColor)
                    })
                }
                // launch prepared session
            }).resume()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    

}

