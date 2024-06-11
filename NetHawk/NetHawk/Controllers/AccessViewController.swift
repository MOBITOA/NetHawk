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
    
    @IBOutlet weak var ipLogo: UILabel!
    @IBOutlet weak var ipFrame: UIView!
    @IBOutlet weak var ipTextField: UITextField!
    
    @IBOutlet weak var portLogo: UILabel!
    @IBOutlet weak var portFrame: UIView!
    @IBOutlet weak var portTextField: UITextField!
    
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var banBtn: UIButton!
    
    @IBOutlet weak var banTextView: UITextView!
    @IBOutlet weak var openTextView: UITextView!
    
    @IBOutlet weak var banContainer: UIView!
    @IBOutlet weak var openContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad : AccessView")
        self.titleLogo.alpha = 0.0
        self.ipLogo.alpha = 0.0
        self.ipFrame.alpha = 0.0
        self.ipTextField.alpha = 0.0
        self.ipTextField.text = ""
        self.portLogo.alpha = 0.0
        self.portFrame.alpha = 0.0
        self.portTextField.alpha = 0.0
        self.portTextField.text = ""
        self.openBtn.alpha = 0.0
        self.banBtn.alpha = 0.0
        self.banContainer.alpha = 0.0
        self.openContainer.alpha = 0.0
        self.banTextView.alpha = 0.0
        self.openTextView.alpha = 0.0
        
        frameConfig(to: ipFrame)
        frameConfig(to: portFrame)
        
        tvConfig(to: banTextView, container: banContainer)
        tvConfig(to: openTextView, container: openContainer)
        
        ipTextField.delegate = self
        portTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 1초 지연 후에 애니메이션 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.applyAnimations()
        }
    }
    
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
        UIView.animate(withDuration: 1, delay: 0.1, options: .curveEaseInOut, animations: {
            self.titleLogo.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0.3, options: .curveEaseInOut, animations: {
            self.ipLogo.alpha = 1.0
            self.ipFrame.alpha = 1.0
            self.ipTextField.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut, animations: {
            self.portLogo.alpha = 1.0
            self.portFrame.alpha = 1.0
            self.portTextField.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0.7, options: .curveEaseInOut, animations: {
            self.openBtn.alpha = 1.0
            self.banBtn.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: 0.9, options: .curveEaseInOut, animations: {
            self.banTextView.alpha = 1.0
            self.banContainer.alpha = 1.0
            self.openTextView.alpha = 1.0
            self.openContainer.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction func dissmissBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension AccessViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == ipTextField {
            // 브로커 텍스트필드 입력 시 버튼 숨김 여부 결정
            let ipTextIsEmpty = ipTextField.text?.isEmpty ?? true
            let portTextIsEmpty = portTextField.text?.isEmpty ?? true
            
            if ipTextIsEmpty {
                openBtn.isEnabled = false
            } else {
                openBtn.isEnabled = true
            }
            
            if portTextIsEmpty {
                banBtn.isEnabled = false
            } else {
                banBtn.isEnabled = true
            }
            
            return true
            
        } else if textField == portTextField {
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            _ = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
            
            let formattedText = prospectiveText.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "-", with: "")
            
            if formattedText.count > 12 {
                return false
            }
            
            let macAddress = formatMACAddress(formattedText)
            
            textField.text = macAddress
            
            // MAC 텍스트필드 입력 시 버튼 숨김 여부 결정
            let ipTextIsEmpty = ipTextField.text?.isEmpty ?? true
            let portTextIsEmpty = portTextField.text?.isEmpty ?? true
            
            if ipTextIsEmpty {
                openBtn.isEnabled = false
            } else {
                openBtn.isEnabled = true
            }
            
            if portTextIsEmpty {
                banBtn.isEnabled = false
            } else {
                banBtn.isEnabled = true
            }
            
            return false
        }
        return true
    }
    func formatMACAddress(_ macAddress: String) -> String {
        var formattedMACAddress = ""
        var index = 0
        
        for char in macAddress {
            formattedMACAddress.append(char)
            
            if (index + 1) % 2 == 0 && index < macAddress.count - 1 {
                formattedMACAddress.append(":")
            }
            
            index += 1
        }
        
        return formattedMACAddress
    }
}


