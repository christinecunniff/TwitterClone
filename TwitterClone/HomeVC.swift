import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var avaImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // array to store tweets
    var tweets = [AnyObject]()
    var images = [UIImage]()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPosts()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PostCell
        
        let tweet = tweets[indexPath.row]
        let image = images[indexPath.row]
        let username = tweet["username"] as? String
        let text = tweet["text"] as? String
        let date = tweet["date"] as! String
        
        // caonverting date string ot date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormatter.date(from: date)!
        
        //declare settings
        let from = newDate
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from, to: now, options: [])
        
        // calculate date
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(difference.second)s." // 12s.
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(difference.minute)m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour)h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(difference.day)d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth)w."
        }
        
        cell.usernameLbl.text = username
        cell.textLbl.text = text
        cell.picImg.image = image
        
        DispatchQueue.main.async {
            
            cell.textLbl.sizeToFit()
            
            // move text left if there is no pic
            if image.size.width == 0 && image.size.height == 0 {
                cell.textLbl.frame.origin.x = self.view.frame.size.width / 16
                cell.textLbl.frame.size.width = self.view.frame.size.width - self.view.frame.size.width / 8
            }
            
        }
       
        
        return cell
    }
    
    func loadPosts() {
        
        // shortcut to id
        let id = user!["id"] as! String
        
        let url = URL(string: "http://localhost/TwitterClone/posts.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(id)&text=&uuid="
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            DispatchQueue.main.async(execute: {
                
                if error == nil {
                    
                    do {
                    
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.tweets.removeAll(keepingCapacity: false)
                        self.images.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        guard let posts = parseJSON["posts"] as? [AnyObject] else {
                            print("Error while getting pots")
                            return
                        }

                        // append all post var's info to tweets
                        self.tweets = posts
                        
                        // getting images from url paths
                        for i in 0..<self.tweets.count {
                            let path = self.tweets[i]["path"] as? String
                            
                            if !path!.isEmpty {
                                let url = URL(string: path!)!
                                let imageData = try? Data(contentsOf: url)
                                let image = UIImage(data: imageData!)!
                                self.images.append(image)
                            } else {
                                let image = UIImage()
                                self.images.append(image)
                            }
                        }
                        
                        self.tableView.reloadData()
                        
                    } catch {
                        print("Caught an error: \(error)")
                    }
                    
                } else {
                    print("error: \(error)")
                }
                
            })
            
        }.resume()
        
    }
    
        
}

// Creating protocol of appending string to var of type data
extension NSMutableData {
    
    func appendString(_ string : String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
        
    }
    
}


