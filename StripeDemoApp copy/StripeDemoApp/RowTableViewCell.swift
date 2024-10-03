//
//  RowTableViewCell.swift
//  DemoApp
//
//  Created by Abilash Joseph  on 30/09/24.
//

import UIKit

class RowTableViewCell: UITableViewCell {

    @IBOutlet weak var ConnectedImage: UIImageView!
    @IBOutlet weak var PaymenType: UILabel!
    var ConnectedReader : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ConnectedImage.image = UIImage(systemName: "checkmark.circle.fill")
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
