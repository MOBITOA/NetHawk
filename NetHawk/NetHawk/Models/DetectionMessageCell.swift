//
//  DetectionMessageCellTableViewCell.swift
//  NetHawk
//
//  Created by mobicom on 10/8/24.
//

import UIKit

class DetectionMessageCell: UITableViewCell {

    @IBOutlet weak var attackImage: UIImageView!
    @IBOutlet weak var victimDeviceLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var typeOfAttackLabel: UILabel!
    @IBOutlet weak var addressOfInvaderLabel: UILabel!
    @IBOutlet weak var addressOfVictimLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        print("awakeFromNib() called")

        print(typeOfAttackLabel.text!)
        if (typeOfAttackLabel.text!) == "Domain Phishing" {
            attackImage.image = #imageLiteral(resourceName: "phishing")
        } else {
            attackImage.image = #imageLiteral(resourceName: "tcp")
        }
        attackImage.layer.cornerRadius = attackImage.frame.width / 2

    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
