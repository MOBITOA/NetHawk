//
//  ViewController.swift
//  PackeTracker
//
//  Created by mobicom on 6/4/24.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - UI Buttons
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var alertBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleBtn.setTitle(".NETHAWK", for: .normal)
        
        titleBtn.layer.shadowColor = UIColor.gray.cgColor
        titleBtn.layer.shadowOpacity = 0.4
        titleBtn.layer.shadowOffset = CGSize(width: 4, height: 3)
        titleBtn.layer.shadowRadius = 4
        
        titleBtn.translatesAutoresizingMaskIntoConstraints = false
    }


}

