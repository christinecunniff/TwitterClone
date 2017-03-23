import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var avaImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // array to store tweets
    var tweets = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get user details from user gloal var
        let username = (user!["username"] as AnyObject).uppercased
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
        
        tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
        tweets = ["hello", "world", "how", "are", "you"]
    }

    @IBAction func editProfileTapped(_ sender: UIButton) {
        
        // select ava
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    // selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // call func of uploading file to server
        uploadAva()
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
    
    // upload image to serve
    func uploadAva() {
        
        // shotcut id
        let id = user!["id"] as! String
        
        // url path to php file
        let url = URL(string: "http://localhost/TwitterClone/uploadAva.php")!
        
        // declare request to this file
        var request = URLRequest(url: url)
        
        // declare method of passign inf to this file
        request.httpMethod = "POST"
        
        // param to be sent in body of request
        let param = ["id" : id]
        
        // body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // compress image and assign to imageData var
        let imageData = UIImageJPEGRepresentation(avaImage.image!, 0.5)
        
        // if not compressed, return ... do not continue to code
        if imageData == nil {
            return
        }
        
        // ... body
        request.httpBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        
        // launc session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
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
                                appDelegate.infoView(message: message, color: redSmoothColor)
                            })
                            
                        }
                        
                        // error while jsoning
                    } catch {
                        
                        // get main queue to communicate back to user
                        DispatchQueue.main.async(execute: {
                            let message = error as! String
                            appDelegate.infoView(message: message, color: redSmoothColor)
                        })
                        
                    }
                    
                    // error with php
                } else {
                    
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: redSmoothColor)
                    })
                    
                }
                
                
            })
            
            }.resume()
        
    }
    
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        // remove saved info
        UserDefaults.standard.removeObject(forKey: "parseJSON")
        UserDefaults.standard.synchronize()
        
        //go to login page
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.present(loginVC, animated: false, completion: nil)
    }
    
    // MARK: TableView methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PostCell
        cell?.usernameLbl.text = tweets[indexPath.row]
        cell?.textLbl.text = tweets[indexPath.row]
        
        DispatchQueue.main.async {
            cell?.textLbl.sizeToFit()
        }
        
        cell?.picImg.image = UIImage(named: "ava.jpg")
        
        return cell!
    }
    
        
}

// Creating protocol of appending string to var of type data
extension NSMutableData {
    
    func appendString(_ string : String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
        
    }
    
}


