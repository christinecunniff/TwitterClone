import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var avaImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get user details from user gloal var
        let username = (user!["username"] as? String)?.uppercased()
        let fullname = user!["fullname"] as? String
        let email = user!["email"] as? String
        let ava = user!["ava"] as? String
        
        // assign values to labels
        userNameLabel.text = username
        fullNameLabel.text = fullname
        emailLabel.text = email
        
        if ava != "" {
            // url path to image
            let imageURL = URL(string: ava!)!
            
            // communicate back user as main queue
            DispatchQueue.main.async(execute: {
                
                // get data from image url
                let imageData = try? Data(contentsOf: imageURL)
                
                // if data is not nil assign it to ava.Img
                if imageData != nil {
                    DispatchQueue.main.async(execute: {
                        self.avaImage.image = UIImage(data: imageData!)
                    })
                }
            })
            
        }
        
        // round corners
        avaImage.layer.cornerRadius = avaImage.bounds.width / 20
        avaImage.clipsToBounds = true
        
        self.navigationItem.title = username
        editBtn.setTitleColor(brandBlueColor, for: .normal)
    }

    @IBAction func editProfileTapped(_ sender: UIButton) {
        
        // select ava
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            avaImage.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avaImage.image = image
        } else {
            avaImage.image = nil
        }
    }
    
    // custom body of HTTP request to upload image file
    func createBodyWithParams(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "ava.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
        
    }
    
    // upload image to server
    func uploadAva() {
        
        let id = user!["id"] as! String
    
        let url = URL(string: "http://localhost/TwitterClone/uploadAva.php")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let param = ["id" : id]
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(avaImage.image!, 0.5)
        
        if imageData == nil {
            return
        }
        
        request.httpBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary) as Data
        
        // launc session
        URLSession.shared.dataTask(with: url, completionHandler: { (data:Data?, response: URLResponse?, error: NSError?) in
            
            // get main queue to communicate back to user
            DispatchQueue.main.async(execute: {
                
                if error == nil {
                    
                    do {
                        // json containes $returnArray from php
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // get id from $returnArray["id"] - parseJSON["id"]
                        let id = parseJSON["id"]
                        
                        // successfully uploaded
                        if id != nil {
                            
                            // save user information we received from our host
                            UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                            user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                            
                            // did not give back "id" value from server
                        } else {
                            
                            // get main queue to communicate back to user
                            DispatchQueue.main.async(execute: {
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(mesage: message, color: redSmoothColor)
                            })
                            
                        }
                        
                        // error while jsoning
                    } catch {
                        
                        // get main queue to communicate back to user
                        DispatchQueue.main.async(execute: {
                            let message = error as! String
                            appDelegate.infoView(mesage: message, color: redSmoothColor)
                        })
                        
                    }
                    
                    // error with php
                } else {
                    
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(mesage: message, color: redSmoothColor)
                    })
                    
                }
                
                
            })
            
        } as! (Data?, URLResponse?, Error?) -> Void).resume()
        
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        // remove saved info
        UserDefaults.standard.removeObject(forKey: "parseJSON")
        UserDefaults.standard.synchronize()
        
        //go to login page
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.present(loginVC, animated: false, completion: nil)
    }
    
        
}

// Creating protocol of appending string to var of type data
extension NSMutableData {
    
    func appendString(_ string : String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
        
    }
    
}


