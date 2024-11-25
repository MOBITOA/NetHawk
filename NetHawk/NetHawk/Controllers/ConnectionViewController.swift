//
//  ConnectionViewController.swift
//  NetHawk
//
//  Created by mobicom on 6/6/24.
//

import UIKit
import CocoaMQTT

class ConnectionViewController: UIViewController {

    // MARK: - UI Outlets
    @IBOutlet weak var logoLabel: UIButton!
    @IBOutlet weak var inputLabelOne: UILabel!
    @IBOutlet weak var inputLabelTwo: UILabel!
    @IBOutlet weak var tfFrameOne: UIView!
    @IBOutlet weak var tfFrameTwo: UIView!
    @IBOutlet weak var serialNumberTextField: UITextField!
    @IBOutlet weak var aliasTextField: UITextField!
    @IBOutlet weak var pairingBtn: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var portSegmentedControl: UISegmentedControl!

    // MARK: - LifeCycle and UI Design
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIForDevice()
        self.logoLabel.alpha = 0.0
        self.inputLabelOne.alpha = 0.0
        self.inputLabelTwo.alpha = 0.0
        self.tfFrameOne.alpha = 0.0
        self.tfFrameTwo.alpha = 0.0
        self.pairingBtn.alpha = 0.0
        self.portSegmentedControl.alpha = 0.0
        self.logoImageView.alpha = 0.0
        self.serialNumberTextField.text = "8FB18CAE5EDC65C6"
        self.aliasTextField.text = ""

        frameConfig(to: tfFrameOne)
        frameConfig(to: tfFrameTwo)

        serialNumberTextField.delegate = self
        aliasTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        serialNumberTextField.clearButtonMode = .whileEditing
        aliasTextField.clearButtonMode = .whileEditing

        // 만약 이미 저장된 정보가 있으면 MQTT 연결 시도
        if let credentials = KeychainManager.shared.load() {
            let serialNumber = credentials.serialNumber
            let alias = credentials.alias

            if !serialNumber.isEmpty && !alias.isEmpty {
                connectToMQTTBroker(serialNumber: serialNumber, alias: alias)
            }
        }

        // 저장된 네트워크 타입 불러오기
        let savedNetworkType = UserDefaults.standard.integer(forKey: "SelectedNetworkType")
        portSegmentedControl.selectedSegmentIndex = savedNetworkType
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.applyAnimations()
        }
    }

    // MARK: - Port 설정 세그먼트 컨트롤
    @IBAction func portSegmentedChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(portSegmentedControl.selectedSegmentIndex, forKey: "SelectedNetworkType")
        case 1:
            UserDefaults.standard.set(portSegmentedControl.selectedSegmentIndex, forKey: "SelectedNetworkType")
        default:
            break
        }
    }
    // MARK: - UI 설정 함수들
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
        UIView.animate(withDuration: 1, delay: 0.1, options: .curveEaseInOut, animations: {
            self.logoLabel.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.2, options: .curveEaseInOut, animations: {
            self.portSegmentedControl.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.3, options: .curveEaseInOut, animations: {
            self.inputLabelOne.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut, animations: {
            self.tfFrameOne.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.7, options: .curveEaseInOut, animations: {
            self.inputLabelTwo.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 0.9, options: .curveEaseInOut, animations: {
            self.tfFrameTwo.alpha = 1.0
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 1.1, options: .curveEaseInOut, animations: {
            self.pairingBtn.alpha = 1.0
            self.pairingBtn.isEnabled = false
        }, completion: nil)

        UIView.animate(withDuration: 1, delay: 1.3, options: .curveEaseInOut, animations: {
            self.logoImageView.alpha = 0.1
        }, completion: nil)
    }

    func setupUIForDevice() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad용 UI 설정
            // 기존 제약 조건 제거
            if let existingConstraint = view.constraints.first(where: {
                $0.firstItem as? UIView == logoLabel && $0.firstAttribute == .top
            }) {
                view.removeConstraint(existingConstraint)
            }

            // 새로운 제약 조건 추가
            logoLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
                logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
            // portSegmentedControl 크기 조정
            portSegmentedControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)

            // inputLabel 크기 조정 (커스텀 폰트 적용)
            if let customFont = inputLabelOne.font {
                inputLabelOne.font = customFont.withSize(22)
                inputLabelTwo.font = customFont.withSize(22)
            }

            // 텍스트 필드 크기 조정 (커스텀 폰트 적용)
            if let customFont = serialNumberTextField.font {
                serialNumberTextField.font = customFont.withSize(20)
                aliasTextField.font = customFont.withSize(20)
            }

            // Auto Layout 제약 조건으로 길이 동기화
            serialNumberTextField.translatesAutoresizingMaskIntoConstraints = false
            aliasTextField.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                // 텍스트 필드의 동일한 너비
                serialNumberTextField.widthAnchor.constraint(equalTo: aliasTextField.widthAnchor),

                // 특정 고정 너비 설정 (선택 사항)
                serialNumberTextField.widthAnchor.constraint(equalToConstant: 300),
            ])

            // 버튼 크기 조정 (커스텀 폰트 적용)
            if let customFont = pairingBtn.titleLabel?.font {
                pairingBtn.titleLabel?.font = customFont.withSize(80)
            }
            pairingBtn.layer.cornerRadius = 12

            // 이미지 크기 조정
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.transform = CGAffineTransform(scaleX: 3.5, y: 3.5)
        }
    }


    // MARK: - MQTT 연결 및 관련 메서드

    @IBAction func pairingBtnTapped(_ sender: UIButton) {
        let serialNumber = serialNumberTextField.text ?? ""
        let alias = aliasTextField.text ?? ""

        if portSegmentedControl.selectedSegmentIndex == 0 {
            MQTTService.shared.configure(clientID: alias, host: "203.230.104.207", port: 14025)
            print("internal")
        } else {
            MQTTService.shared.configure(clientID: alias, host: "203.230.104.207", port: 80)
            print("external")
        }

        // 키체인에 S/N과 별칭 저장
        KeychainManager.shared.save(serialNumber: serialNumber, alias: alias)

        connectToMQTTBroker(serialNumber: serialNumber, alias: alias)
    }

    // MQTT 브로커 연결
    func connectToMQTTBroker(serialNumber: String, alias: String) {
        // MQTT 설정
        let portIndex = UserDefaults.standard.integer(forKey: "SelectedNetworkType")
        var port = 0

        if portIndex == 0 {
            port = 14025
        } else {
            port = 80
        }

        MQTTService.shared.configure(clientID: alias, host: "203.230.104.207", port: UInt16(port))
        MQTTService.shared.connect()

        MQTTService.shared.onConnectionSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.navigateToMainViewController()
            }
        }

        MQTTService.shared.onConnectionFailure = { [weak self] in
            DispatchQueue.main.async {
                self?.presentConnectionErrorAlert()
            }
        }
    }

    // 연결 실패 시, 알림창
    func presentConnectionErrorAlert() {
        let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to MQTT broker. Please check the details and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.pairingBtnTapped(UIButton())
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    // MainViewController로 이동
    private func navigateToMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            if let navigationController = navigationController {
                navigationController.pushViewController(mainViewController, animated: true)
            } else {
                mainViewController.modalPresentationStyle = .fullScreen
                present(mainViewController, animated: true, completion: nil)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: 0.3) {
            self.logoLabel.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
            self.inputLabelOne.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
            self.inputLabelTwo.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
            self.tfFrameOne.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
            self.tfFrameTwo.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
//            self.serialNumberTextField.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
//            self.aliasTextField.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
            self.pairingBtn.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
            self.portSegmentedControl.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.logoLabel.transform = .identity
            self.inputLabelOne.transform = .identity
            self.inputLabelTwo.transform = .identity
            self.tfFrameOne.transform = .identity
            self.tfFrameTwo.transform = .identity
            self.serialNumberTextField.transform = .identity
            self.aliasTextField.transform = .identity
            self.pairingBtn.transform = .identity
            self.portSegmentedControl.transform = .identity
        }
    }

}

// UITextFieldDelegate 확장
extension ConnectionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let serialNumberIsEmpty = serialNumberTextField.text?.isEmpty ?? true
        let aliasIsEmpty = aliasTextField.text?.isEmpty ?? true

        pairingBtn.isEnabled = !(serialNumberIsEmpty || aliasIsEmpty)
        return true
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
