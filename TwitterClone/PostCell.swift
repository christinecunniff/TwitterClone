import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var textLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLbl.textColor = brandBlueColor
        picImg.layer.cornerRadius = picImg.bounds.width / 20
        picImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
