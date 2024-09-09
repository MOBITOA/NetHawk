//
//  KeyChainService.swift
//  NetHawk
//
//  Created by mobicom on 6/6/24.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    func save(ip: String, port: String, mac: String) {
        let formattedMac = mac.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "-", with: "")

        let ipData = Data(ip.utf8)
        let portData = Data(port.utf8)
        let macData = Data(formattedMac.utf8)

        let ipQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "IPAddress",
            kSecValueData as String: ipData
        ]

        let portQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "PortNumber",
            kSecValueData as String: portData
        ]

        let macQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MACAddress",
            kSecValueData as String: macData
        ]

        // 기존 키 체인 항목을 업데이트하거나 추가
        SecItemDelete(ipQuery as CFDictionary)
        SecItemAdd(ipQuery as CFDictionary, nil)

        SecItemDelete(portQuery as CFDictionary)
        SecItemAdd(portQuery as CFDictionary, nil)

        SecItemDelete(macQuery as CFDictionary)
        SecItemAdd(macQuery as CFDictionary, nil)

        print("Keychain Saved: IP \(ip), Port \(port), MAC \(formattedMac)")
    }

    func load() -> (ip: String, port: String, mac: String)? {
        let ipQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "IPAddress",
            kSecReturnData as String: true
        ]

        let portQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "PortNumber",
            kSecReturnData as String: true
        ]

        let macQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MACAddress",
            kSecReturnData as String: true
        ]

        var ipData: AnyObject?
        var portData: AnyObject?
        var macData: AnyObject?

        let ipStatus = SecItemCopyMatching(ipQuery as CFDictionary, &ipData)
        let portStatus = SecItemCopyMatching(portQuery as CFDictionary, &portData)
        let macStatus = SecItemCopyMatching(macQuery as CFDictionary, &macData)

        if ipStatus == errSecSuccess, let ipData = ipData as? Data,
           portStatus == errSecSuccess, let portData = portData as? Data,
           macStatus == errSecSuccess, let macData = macData as? Data {
            let ip = String(data: ipData, encoding: .utf8) ?? ""
            let port = String(data: portData, encoding: .utf8) ?? ""
            let formattedMac = String(data: macData, encoding: .utf8) ?? ""
            let mac = formatMACAddress(formattedMac)
            return (ip, port, mac)
        }

        return nil
    }

    private func formatMACAddress(_ macAddress: String) -> String {
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
