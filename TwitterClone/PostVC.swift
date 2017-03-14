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
    
    func createBodyWithParams(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        // if file is not selected, it will not upload a file
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
    
    

    @IBAction func postTapped(_ sender: UIButton) {
    
        if !textBox.text.isEmpty && textBox.text.characters.count <= 140 {
            // post
        }
    }

}
