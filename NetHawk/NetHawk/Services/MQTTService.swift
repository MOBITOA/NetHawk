//
//  MQTTService.swift
//  NetHawk
//
//  Created by mobicom on 6/6/24.
//

import CocoaMQTT
import Foundation
import UIKit

class MQTTService: CocoaMQTTDelegate {

    static let shared = MQTTService() // 싱글톤 인스턴스

    private var mqtt: CocoaMQTT?
    var onConnectionSuccess: (() -> Void)?
    var onConnectionFailure: (() -> Void)?
    var onPingReceived: (() -> Void)?
    var onPongReceived: (() -> Void)?
    var onDisconnected: (() -> Void)?

    // private init을 통해 외부에서 새로운 인스턴스를 생성하지 못하게 막음
    private init() { }

    // MQTT 클라이언트를 설정하는 함수
    func configure(clientID: String, host: String, port: UInt16) {
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqtt?.delegate = self
        mqtt?.keepAlive = 30
    }

    func connect() {
        mqtt?.connect()
    }

    func disconnect() {
        mqtt?.disconnect()
    }

    func isConnected() -> Bool {
        return mqtt?.connState == .connected
    }

    func subscribe(topic: String, qos: CocoaMQTTQoS = .qos1) {
        mqtt?.subscribe(topic, qos: qos)
    }

    func unsubscribe(topic: String) {
        mqtt?.unsubscribe(topic)
    }

    func publish(topic: String, message: String, qos: CocoaMQTTQoS = .qos1, retained: Bool = false) {
        mqtt?.publish(topic, withString: message, qos: qos, retained: retained)
    }

    // MARK: - CocoaMQTTDelegate

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            print("MQTT connected")
            onConnectionSuccess?()

            // 로그 초기화하기 (임시)
            LoggingService.shared.clearLogs()

            // 키체인에서 시리얼 넘버와 별칭 로드 & 토픽 구독
            if let credentials = KeychainManager.shared.load() {
                let serialNumber = credentials.serialNumber
                // 연결된 필터 알림 수신
                subscribe(topic: "\(serialNumber)/alarm")
                // 블랙리스트 & 화이트리스트
                subscribe(topic: "\(serialNumber)/blacklist")
                subscribe(topic: "\(serialNumber)/whitelist")
                subscribe(topic: "\(serialNumber)/refreshBW")
            }

        } else {
            print("MQTT connection failed")
            onConnectionFailure?()
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT message published: \(message.string ?? ""), id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT message published with ACK: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let messageString = message.string {
            if let parsedData = parseMQTTMessage(messageString) {
                if let data = parsedData["data"] as? [String: Any],
                   let timestamp = data["timestamp"] as? String,
                   let type = data["type"] as? String,
                   let invaderAddress = data["invader_address"] as? String?, // null 값을 고려하여 옵셔널 처리
                   let victimAddress = data["victim_address"] as? String,
                   let victimName = data["victim_name"] as? String {

                    let logEntry = Log(timestamp: timestamp, type: type, invaderAddress: invaderAddress, victimAddress: victimAddress, victimName: victimName)

                    // 로깅 서비스에 LogEntry 구조체로 저장
                    LoggingService.shared.logMessage(logEntry)

                    // NotificationCenter로 로그 추가 알림
                    NotificationCenter.default.post(name: NSNotification.Name("NewLogReceived"), object: nil, userInfo: ["log": logEntry])
                    
                    print("Time Stamp: \(timestamp)\nType: \(type)\nInvader Address: \(String(describing: invaderAddress!))\nVictim Address: \(victimAddress)\nVictim Name: \(victimName)\n-----------------------------")

                }
            }
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        // print("Successfully subscribed to topics: \(success)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        // print("Successfully unsubscribed from topics: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("-------Server Checking-------")
        print("ping")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("pong")
        print("-----------------------------")
        onPongReceived?()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT disconnected: \(err?.localizedDescription ?? "")")
        onDisconnected?()
        onConnectionFailure?()
    }

    // MARK: - Log 관련
    // 로그 파싱 함수
    func parseMQTTMessage(_ message: String) -> [String: Any]? {
        if let data = message.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                return json
            } catch {
                print("Error parsing MQTT message: \(error)")
            }
        }
        return nil
    }
}
