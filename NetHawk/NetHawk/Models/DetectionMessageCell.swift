//
//  DetectionMessageCellTableViewCell.swift
//  NetHawk
//
//  Created by mobicom on 10/8/24.
//

import UIKit

class DetectionMessageCell: UITableViewCell {

    @IBOutlet weak var attackImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        print("awakeFromNib() called")

        attackImage.layer.cornerRadius = attackImage.frame.width / 2

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
