//
//  ViewController.swift
//  PackeTracker
//
//  Created by mobicom on 6/4/24.
//

import UIKit
import CoreLocation
import SystemConfiguration

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - UI Buttons
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var alertBtn: UIButton!
    
    @IBOutlet weak var logBtn: UIButton!
    @IBOutlet weak var statsBtn: UIButton!
    @IBOutlet weak var ipBtn: UIButton!
    // MARK: - UI Labels
    @IBOutlet weak var wifiStatusLabel: UILabel!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let wifiService = WiFiService()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleButton()
        setupWifiStatusLabel()
        
        applyButtonEffect(logBtn)
        applyButtonEffect(statsBtn)
        applyButtonEffect(ipBtn)
    
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    // MARK: - Layout Config
    private func setupTitleButton() {
        titleBtn.setTitle(".NETHAWK", for: .normal)
        titleBtn.layer.shadowColor = UIColor.gray.cgColor
        titleBtn.layer.shadowOpacity = 0.4
        titleBtn.layer.shadowOffset = CGSize(width: 4, height: 3)
        titleBtn.layer.shadowRadius = 4
        titleBtn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupWifiStatusLabel() {
        wifiStatusLabel.textAlignment = .center
        wifiStatusLabel.numberOfLines = 0
        wifiStatusLabel.font = UIFont(name: "IntelOneMono-Light", size: 20)
    }
    
    // MARK: - Alert [위치동의]
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted")
            updateWiFiInfo()
        default:
            print("Location permission not granted")
            wifiStatusLabel.text = "Location permission not granted"
        }
    }
    
    func updateWiFiInfo() {
        print("updateWiFiInfo: Checking WiFi information")
        if let ipAddress = wifiService.getWiFiAddress() {
            print("updateWiFiInfo: IP address found - \(ipAddress)")
            wifiStatusLabel.text = "IP : \(ipAddress)"
        } else {
            print("updateWiFiInfo: No WiFi connection found")
            wifiStatusLabel.text = "WiFi 연결 안됨"
        }
    }
    
    
    @IBAction func logBtnTapped(_ sender: Any) {
    }
    
    func applyButtonEffect(_ button: UIButton) {
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.5
        }
    }

    @objc func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            sender.alpha = 1.0
        }
    }
}
