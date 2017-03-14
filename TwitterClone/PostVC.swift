import UIKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var pictureImg: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    
    
    var uuid = String()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textBox.layer.cornerRadius = textBox.bounds.width / 50
        postBtn.layer.cornerRadius = postBtn.bounds.width / 20
        
        selectBtn.setTitleColor(brandBlueColor, for: .normal)
        postBtn.backgroundColor = brandBlueColor
        countLabel.textColor = graySmoothColor
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // disable button until text is entered
        postBtn.isEnabled = false
        postBtn.alpha = 0.4
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        // counter
        let chars = textView.text.characters.count
        let spacing = CharacterSet.whitespacesAndNewlines
        
        countLabel.text = String(140 - chars)
        
        if chars > 140 {
            countLabel.textColor = redSmoothColor
            postBtn.isEnabled = false
            postBtn.alpha = 0.4
        } else if textView.text.trimmingCharacters(in: spacing).isEmpty {
            postBtn.isEnabled = false
            postBtn.alpha = 0.4
        } else {
            countLabel.textColor = graySmoothColor
            postBtn.isEnabled = true
            postBtn.alpha = 1
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    @IBAction func selectPictureTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        pictureImg.image = image
        self.dismiss(animated: true, completion: nil)
        
        imageSelected = true
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

        // if file is not selected, it will not upload a file to server, because we did not declare a name file
        var filename = ""
        
        if imageSelected == true {
            filename = "post-\(uuid).jpg"
        }

        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
        
    }
    
    // function sending requset to PHP to uplaod a file
    func uploadPost() {
        
        // shortcuts to data to be passed to php file
        let id = user!["id"] as! String
        uuid = UUID().uuidString
        let text = textBox.text as String
        
        
        // url path to php file
        let url = URL(string: "http://localhost/TwitterClone/posts.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // param to be passed to php file
        let param = [
            "id" : id,
            "uuid" : uuid,
            "text" : text
        ]
        
        // body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if picture is selected, compress it by half
        var imageData = Data()
        
        if pictureImg.image != nil {
            imageData = UIImageJPEGRepresentation(pictureImg.image!, 0.5)!
        }
        
        // ... body
        request.httpBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queu to communicate back to user
            DispatchQueue.main.async(execute: {
                
                
                if error == nil {
                    
                    do {
                        
                        // json containes $returnArray from php
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // declare new var to store json inf
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // get message from $returnArray["message"]
                        let message = parseJSON["message"]
                        
                        // if there is some message - post is made
                        if message != nil {
                            
                            // reset UI
                            self.textBox.text = ""
                            self.countLabel.text = "140"
                            self.pictureImg.image = nil
                            self.postBtn.isEnabled = false
                            self.postBtn.alpha = 0.4
                            self.imageSelected = false
                            
                            // switch to another scene
                            self.tabBarController?.selectedIndex = 0
                            
                        }
                        
                    } catch {
                        
                        // get main queue to communicate back to user
                        DispatchQueue.main.async(execute: {
                            let message = "\(error)"
                            appDelegate.infoView(message: message, color: redSmoothColor)
                        })
                        return
                        
                    }
                    
                } else {
                    
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: redSmoothColor)
                    })
                    return
                    
                }
                
                
            })
            
            }.resume()
        
    }
    
    @IBAction func postTapped(_ sender: UIButton) {
    
        if !textBox.text.isEmpty && textBox.text.characters.count <= 140 {
            uploadPost()
        }
    }

}
