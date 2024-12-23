//
//  OptionViewController.swift
//  PackeTracker
//
//  Created by mobicom on 6/4/24.
//

import UIKit

class OptionViewController: UIViewController {

    @IBOutlet weak var networkTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var alarmSegmentControl: UISegmentedControl!
    @IBOutlet weak var changeDeviceBtn: UIButton!
    
    private let networkTypeKey = "SelectedNetworkType"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 스와이프 제스처 추가
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .right // 오른쪽으로 스와이프하면 닫힘
        self.view.addGestureRecognizer(swipeGesture)

        // 저장된 알람 타입 불러오기
        let savedAlarmType = UserDefaults.standard.integer(forKey: "notificationEnabled")
        alarmSegmentControl.selectedSegmentIndex = savedAlarmType

        // 저장된 네트워크 타입 불러오기
        let savedNetworkType = UserDefaults.standard.integer(forKey: networkTypeKey)
        networkTypeSegmentControl.selectedSegmentIndex = savedNetworkType

        // 세그먼트 컨트롤에 타겟-액션 추가
        networkTypeSegmentControl.addTarget(self, action: #selector(networkTypeChanged), for: .valueChanged)
        networkTypeChanged()
    }

    @IBAction func alarmTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(0, forKey: "notificationEnabled")
            print("Option : 알림 기능을 켭니다.")
        case 1:
            UserDefaults.standard.set(1, forKey: "notificationEnabled")
            print("Option : 알림 기능을 끕니다.")
        default:
            break
        }
    }

    @objc private func networkTypeChanged() {
        MQTTService.shared.connect()
        UserDefaults.standard.set(networkTypeSegmentControl.selectedSegmentIndex, forKey: networkTypeKey)

        switch networkTypeSegmentControl.selectedSegmentIndex {
        case 0:
            applyInternalNetworkSettings()
        case 1:
            applyExternalNetworkSettings()
        default:
            break
        }
    }
    private func applyInternalNetworkSettings() {
        print("Internal network settings applied")
        // TODO: 내부 네트워크 관련 로직 구현
        if let credentials = KeychainManager.shared.load() {
            let alias = credentials.alias
            MQTTService.shared.configure(clientID: alias, host: "203.230.104.207", port: 14025)
            MQTTService.shared.disconnect()
            MQTTService.shared.connect()
        }
    }

    private func applyExternalNetworkSettings() {
        print("External network settings applied")
        if let credentials = KeychainManager.shared.load() {
            let alias = credentials.alias
            MQTTService.shared.configure(clientID: alias, host: "203.230.104.207", port: 80)
            MQTTService.shared.disconnect()
            MQTTService.shared.connect()
        }
    }
    @IBAction func changingDeviceBtn(_ sender: UIButton) {

        MQTTService.shared.disconnect()

        KeychainManager.shared.clear()

        if let window = UIApplication.shared.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let connectionViewController = storyboard.instantiateViewController(withIdentifier: "ConnectionViewController") as? ConnectionViewController {
                window.rootViewController = connectionViewController
                window.makeKeyAndVisible()
            }
        }
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        // 현재 모달 화면 닫기
        self.dismiss(animated: true, completion: nil)
    }
}
