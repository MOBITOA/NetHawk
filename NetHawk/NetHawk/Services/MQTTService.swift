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
        print("MQTT message received: \(message.string ?? ""), id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("Successfully subscribed to topics: \(success)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("Successfully unsubscribed from topics: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("ping")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("pong")
        onPongReceived?()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT disconnected: \(err?.localizedDescription ?? "")")
        onDisconnected?()
        onConnectionFailure?()
    }
}
