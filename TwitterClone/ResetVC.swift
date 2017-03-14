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
            
            let email = emailField.text!.lowercased()
            
            // if text is entered, send mysql/php/hosting request
            
            // url path to php file
            let url = NSURL(string: "http://localhost/TwitterClone/resetPassword.php")!
            
            // request to send this file
            let request = NSMutableURLRequest(url: url as URL)
            
            // method of passing info to this file
            request.httpMethod = "POST"
            
            // body to be appended to URL - it passes info to our php file
            let body = "email=\(email)"
            request.httpBody = body.data(using: String.Encoding.utf8)
            
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error == nil {
                
                    // give main queue to UI to communicate back
                    DispatchQueue.main.async(execute: {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            
                            guard let parseJSON = json else {
                                print("Error while parsing")
                                return
                            }
                            
                            let email = parseJSON["email"]
                            
                            // successful reset
                            if email != nil {
                                DispatchQueue.main.async(execute: {
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: lightGreenSmoothColor)
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
                    
                } else {
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: redSmoothColor)
                    })
                }
            }).resume()
            
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
