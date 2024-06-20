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
    
    // MARK: - UI Outlets
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var alertBtn: UIButton!
    
    @IBOutlet weak var logBtn: UIButton!
    @IBOutlet weak var statsBtn: UIButton!
    @IBOutlet weak var ipBtn: UIButton!
    
    @IBOutlet weak var wifiStatusTitle: UILabel!
    @IBOutlet weak var wifiStatusLabel: UILabel!
    
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var ipPortLabel: UILabel!
    
    @IBOutlet weak var logo: UIImageView!
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let wifiService = WiFiService()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad : MainView")
        setupTitleButton()
        setupWifiStatusLabel()
        
        applyButtonEffect(logBtn)
        applyButtonEffect(statsBtn)
        applyButtonEffect(ipBtn)
        
        addShadowToButton(logBtn)
        addShadowToButton(statsBtn)
        addShadowToButton(ipBtn)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        titleBtn.alpha = 0.0
        alertBtn.alpha = 0.0
        logBtn.alpha = 0.0
        statsBtn.alpha = 0.0
        ipBtn.alpha = 0.0
        wifiStatusLabel.alpha = 0.0
        wifiStatusTitle.alpha = 0.0
        logLabel.alpha = 0.0
        statsLabel.alpha = 0.0
        ipPortLabel.alpha = 0.0
        logo.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 0.1초 지연 후에 애니메이션 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.applyAnimations()
        }
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
    
    private func addShadowToButton(_ button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        button.layer.masksToBounds = false
    }
    
    func applyAnimations() {
        UIView.animate(withDuration: 1, delay: 0.1, options: .curveEaseInOut, animations: {
            self.logo.alpha = 0.15
            
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut, animations: {
            self.titleBtn.alpha = 1.0
            self.alertBtn.alpha = 1.0

        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0.7, options: .curveEaseInOut, animations: {
            self.wifiStatusLabel.alpha = 1.0
            self.wifiStatusTitle.alpha = 1.0

        }, completion: nil)

        
        UIView.animate(withDuration: 1, delay: 0.9, options: .curveEaseInOut, animations: {
            self.logBtn.alpha = 1.0
            self.logLabel.alpha = 1.0
            self.statsBtn.alpha = 1.0
            self.statsLabel.alpha = 1.0
            self.ipBtn.alpha = 1.0
            self.ipPortLabel.alpha = 1.0
        }, completion: nil)
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
    
    
    @IBAction func logBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let logVC = storyboard.instantiateViewController(withIdentifier: "LogViewController") as? LogViewController {
            logVC.modalPresentationStyle = .fullScreen
            present(logVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func statBtntapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let statVC = storyboard.instantiateViewController(withIdentifier: "StatViewController") as? StatViewController {
            statVC.modalPresentationStyle = .fullScreen
            present(statVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func ipBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let accessVC = storyboard.instantiateViewController(withIdentifier: "AccessViewController") as? AccessViewController {
            accessVC.modalPresentationStyle = .fullScreen
            present(accessVC, animated: true, completion: nil)
        }
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
