//
//  AccessControlViewController.swift
//  PackeTracker
//
//  Created by mobicom on 6/4/24.
//

import UIKit

class AccessViewController: UIViewController {

    // MARK: - UI Outlets

    @IBOutlet weak var titleLogo: UILabel!

    @IBOutlet weak var whiteListLabel: UILabel!
    @IBOutlet weak var blackListLabel: UILabel!

    @IBOutlet weak var ipLogo: UILabel!
    @IBOutlet weak var ipFrame: UIView!
    @IBOutlet weak var ipTextField: UITextField!


    @IBOutlet weak var banTextView: UITextView!
    @IBOutlet weak var openTextView: UITextView!
    @IBOutlet weak var banContainer: UIView!
    @IBOutlet weak var openContainer: UIView!


    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var banBtn: UIButton!

    // 화이트리스트, 블랙리스트 리스트
    private var whiteList = [String]()
    private var blackList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 스와이프 제스처 추가
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .right // 오른쪽으로 스와이프하면 닫힘
        self.view.addGestureRecognizer(swipeGesture)

        setupUIForDevice()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBlacklist(notification:)),
            name: NSNotification.Name("UpdateBlacklist"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateWhitelist(notification:)),
            name: NSNotification.Name("UpdateWhitelist"),
            object: nil
        )

        self.titleLogo.alpha = 0.0
        self.ipLogo.alpha = 0.0
        self.ipFrame.alpha = 0.0
        self.ipTextField.alpha = 0.0
        self.ipTextField.text = ""
        self.openBtn.alpha = 0.0
        self.banBtn.alpha = 0.0
        self.banContainer.alpha = 0.0
        self.openContainer.alpha = 0.0
        self.banTextView.alpha = 0.0
        self.openTextView.alpha = 0.0
        self.whiteListLabel.alpha = 0.0
        self.blackListLabel.alpha = 0.0
        self.refreshBtn.alpha = 0.0
        self.openBtn.isEnabled = false
        self.banBtn.isEnabled = false

        frameConfig(to: ipFrame)

        tvConfig(to: banTextView, container: banContainer)
        tvConfig(to: openTextView, container: openContainer)

        ipTextField.delegate = self

        // 페이지 진입 시, 리스트 갱신
        acquireBlackAndWhitelist()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 1초 지연 후에 애니메이션 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.applyAnimations()
        }
    }
    // MARK: - B/W functions

    @IBAction func refreshBtnTapped(_ sender: UIButton) {
        acquireBlackAndWhitelist()
    }

    @IBAction func banBtnTapped(_ sender: UIButton) {
        blackList.append(ipTextField.text!)

        guard let ipToAdd = ipTextField.text, !ipToAdd.isEmpty else { return }

        // Ban 리스트에 추가
        if !blackList.contains(ipToAdd) {
            blackList.append(ipToAdd)
        }

        // Open 리스트에서 제거
        if let index = whiteList.firstIndex(of: ipToAdd) {
            whiteList.remove(at: index)
        }

        modifyBlackAndWhiteList(for: "black")

        updateTextViews()
        ipTextField.text = ""
    }

    @IBAction func openBtnTapped(_ sender: UIButton) {
        whiteList.append(ipTextField.text!)

        guard let ipToAdd = ipTextField.text, !ipToAdd.isEmpty else { return }

        // Open 리스트에 추가
        if !whiteList.contains(ipToAdd) {
            whiteList.append(ipToAdd)
        }

        // Ban 리스트에서 제거
        if let index = blackList.firstIndex(of: ipToAdd) {
            blackList.remove(at: index)
        }

        modifyBlackAndWhiteList(for: "white")

        updateTextViews()
        ipTextField.text = ""
    }

    func updateTextViews() {
        banTextView.text = blackList.joined(separator: "\n")
        openTextView.text = whiteList.joined(separator: "\n")
    }



    /*
     <<블랙리스트 획득>>
     {
     "command": "blacklist_acquire"
     "parameters": {}
     }
     {
     "return": ["blacklisted_ip", "blacklisted_ip", ...] (현재 블랙리스트)
     }


     <<블랙리스트 수정>>
     {
     "command": "blacklist_modify"
     "parameters": {
     "ip_list": ["to_blacklist_ip", "to_blacklist_ip", ...] (변경할 블랙리스트)
     }
     }
     {
     "return": ["blacklisted_ip", "blacklisted_ip", ...] (업데이트 후 블랙리스트)
     }


     <<화이트리스트 획득>>
     {
     "command": "whitelist_acquire"
     "parameters": {}
     }
     {
     "return": ["blacklisted_ip", "blacklisted_ip", ...] (현재 화이트리스트)
     }


     <<화이트리스트 수정>>
     {
     "command": "whitelist_modify"
     "parameters": {
     "ip_list": ["to_whitelist_ip", "to_whitelist_ip", ...] (변경할 화이트리스트)
     }
     }
     {
     "return": ["whitelisted_ip", "whitelisted_ip", ...] (업데이트 후 화이트리스트)
     }

     */

    @objc func updateBlacklist(notification: Notification) {
        if let ipList = notification.userInfo?["blacklist"] as? [String] {
            print("update Blacklist")
            self.blackList = ipList
            self.banTextView.text = ipList.joined(separator: "\n")
        }
    }

    @objc func updateWhitelist(notification: Notification) {
        if let ipList = notification.userInfo?["whitelist"] as? [String] {
            print("update Whitelist")
            self.whiteList = ipList
            self.openTextView.text = ipList.joined(separator: "\n")
        }
    }

    // 블랙, 화이트리스트 변경 메서드
    func modifyBlackAndWhiteList(for target: String) {
        if let credentials = KeychainManager.shared.load() {
            let serialNumber = credentials.serialNumber
            let alias = credentials.alias

            let command: [String: Any]
            let list: [String]

            switch target {
            case "black":
                list = blackList
                command = [
                    "command": "blacklist_modify",
                    "source": alias,
                    "parameters": [
                        "ip_list": list
                    ]
                ]
            case "white":
                list = whiteList
                command = [
                    "command": "whitelist_modify",
                    "source": alias,
                    "parameters": [
                        "ip_list": list
                    ]
                ]
            default:
                print("지원하지 않는 목록 유형입니다.")
                return
            }

            // JSON으로 변환하고 MQTT를 통해 요청을 발행
            if let jsonData = try? JSONSerialization.data(withJSONObject: command, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                let filterID = "\(serialNumber)"
                print("목록 요청 (\(target)): \n\(jsonString)")
                MQTTService.shared.publish(topic: filterID, message: jsonString)
            }
        }
    }
    func acquireBlackAndWhitelist() {
        if let credentials = KeychainManager.shared.load() {
            let serialNumber = credentials.serialNumber
            let alias = credentials.alias

            let blackListCommand = [
                "command": "blacklist_acquire",
                "source": "\(alias)",
                "parameters": [:]
            ] as [String : Any]

            let whiteListCommand = [
                "command": "whitelist_acquire",
                "source": "\(alias)",
                "parameters": [:]
            ] as [String : Any]

            if let blackListJsonData = try? JSONSerialization.data(withJSONObject: blackListCommand, options: []),
               let blackListJsonString = String(data: blackListJsonData, encoding: .utf8) {
                let filterID = "\(serialNumber)"

                // 블랙리스트 요청 발행
                print("블랙리스트 요청: \(blackListJsonString)")
                MQTTService.shared.publish(topic: filterID, message: blackListJsonString)
            }

            if let whiteListJsonData = try? JSONSerialization.data(withJSONObject: whiteListCommand, options: []),
               let whiteListJsonString = String(data: whiteListJsonData, encoding: .utf8) {
                let filterID = "\(serialNumber)"

                // 화이트리스트 요청 발행
                print("화이트리스트 요청: \(whiteListJsonString)")
                MQTTService.shared.publish(topic: filterID, message: whiteListJsonString)
            }
        }
    }


    // MARK: - UI
    func tvConfig(to tv: UITextView, container: UIView) {
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.isEditable = false

        container.layer.cornerRadius = 10
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.3
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.backgroundColor = .white
    }

    func frameConfig(to view: UIView) {
        let cornerRadius: CGFloat = 10
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.3
        let shadowOffset: CGSize = CGSize(width: 0, height: 2)
        let shadowRadius: CGFloat = 4

        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = false
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
    }

    func applyAnimations() {
        UIView.animate(withDuration: 1, delay: 0.05, options: .curveEaseInOut, animations: {
            self.titleLogo.alpha = 1.0
            self.refreshBtn.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.1, options: .curveEaseInOut, animations: {
            self.whiteListLabel.alpha = 1.0
            self.blackListLabel.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.3, options: .curveEaseInOut, animations: {
            self.banTextView.alpha = 1.0
            self.banContainer.alpha = 1.0
            self.openTextView.alpha = 1.0
            self.openContainer.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut, animations: {
            self.openBtn.alpha = 1.0
            self.banBtn.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.7, options: .curveEaseInOut, animations: {
            self.ipLogo.alpha = 1.0
            self.ipFrame.alpha = 1.0
            self.ipTextField.alpha = 1.0
        }, completion: nil)
    }

    // 조정대상 whiteListLabel, blackListLabel, ipLogo, ipFrame, iptextField, banTextView, openTextView, banContainer, openContainer
    func setupUIForDevice() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // whiteListLabel의 Top 제약 조건 수정

            if let whiteListTopConstraint = view.constraints.first(where: {
                $0.firstItem as? UIView == whiteListLabel && $0.firstAttribute == .top
            }) {
                whiteListTopConstraint.constant = 100
            }

            // 기존 높이 제약 조건 제거
            if let existingHeightConstraint = banContainer.constraints.first(where: { $0.firstAttribute == .height }) {
                NSLayoutConstraint.deactivate([existingHeightConstraint])
            }
            if let existingHeightConstraint = openContainer.constraints.first(where: { $0.firstAttribute == .height }) {
                NSLayoutConstraint.deactivate([existingHeightConstraint])
            }

            // banTextView와 openTextView의 기존 높이 제약 조건 제거
            NSLayoutConstraint.deactivate(banTextView.constraints.filter { $0.firstAttribute == .height })
            NSLayoutConstraint.deactivate(openTextView.constraints.filter { $0.firstAttribute == .height })


            // 새로운 높이 제약 조건 추가
            banContainer.translatesAutoresizingMaskIntoConstraints = false
            openContainer.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                banContainer.heightAnchor.constraint(equalToConstant: 250),
                openContainer.heightAnchor.constraint(equalToConstant: 250)
            ])

            openTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                openTextView.topAnchor.constraint(equalTo: openContainer.topAnchor),
                openTextView.bottomAnchor.constraint(equalTo: openContainer.bottomAnchor),
                openTextView.leadingAnchor.constraint(equalTo: openContainer.leadingAnchor),
                openTextView.trailingAnchor.constraint(equalTo: openContainer.trailingAnchor)
            ])

            banTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                banTextView.topAnchor.constraint(equalTo: banContainer.topAnchor),
                banTextView.bottomAnchor.constraint(equalTo: banContainer.bottomAnchor),
                banTextView.leadingAnchor.constraint(equalTo: banContainer.leadingAnchor),
                banTextView.trailingAnchor.constraint(equalTo: banContainer.trailingAnchor)
            ])

            // 레이아웃 강제 업데이트
            view.layoutIfNeeded()


            if let topSpacingConstraint = view.constraints.first(where: {
                ($0.firstItem as? UIView == ipFrame && $0.secondItem as? UIView == ipLogo && $0.firstAttribute == .top && $0.secondAttribute == .bottom)
            }) {
                topSpacingConstraint.constant = 15 // ipFrame과 ipLogo 간의 간격
            }

            if let customFont = whiteListLabel.font {
                whiteListLabel.font = customFont.withSize(33)
                blackListLabel.font = customFont.withSize(33)
                banTextView.font = customFont.withSize(30)
                openTextView.font = customFont.withSize(30)
                ipLogo.font = customFont.withSize(28)
                ipFrame.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                banBtn.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                openBtn.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }

    @IBAction func dissmissBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        // 현재 모달 화면 닫기
        self.dismiss(animated: true, completion: nil)
    }
}

extension AccessViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 텍스트 필드 값이 변경된 후의 텍스트 계산
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)

        // 버튼 활성화 여부 결정
        var ipTextIsEmpty = ipTextField.text?.isEmpty ?? true

        if textField == ipTextField {
            ipTextIsEmpty = updatedText?.isEmpty ?? true
        }

        if !ipTextIsEmpty {
            openBtn.isEnabled = true
            banBtn.isEnabled = true
        } else {
            openBtn.isEnabled = false
            banBtn.isEnabled = false
        }

        return true
    }
}
