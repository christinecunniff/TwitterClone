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
            
            // shortcuts
            let username = usernameField.text!.lowercased()
            let password = passwordField.text!
            
            // send request to mysql db
            // url to access our php file
            let url = NSURL(string: "http://localhost/TwitterClone/login.php")!
            
            // request url
            let request = NSMutableURLRequest(url: url as URL)
            
            // method to pass data POST- it is secured
            request.httpMethod = "POST"
            
            // body appended to url (won't be seen because we are using post)
            let body = "username=\(username)&password=\(password)"
            request.httpBody = body.data(using: String.Encoding.utf8)
            
            // launch session
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error == nil {
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        print(parseJSON)
                        
                        let id = parseJSON["id"] as? String
                        
                        if id != nil {
                            // successfully logged in
                        }
                    } catch {
                        print("Caught an error: \(error)")
                    }
                    
                } else {
                    print("Error: \(error)")
                }
                
            }).resume()
        }
        
    }

}
