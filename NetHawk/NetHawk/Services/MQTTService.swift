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
    
    private var mqtt: CocoaMQTT?
    var onConnectionSuccess: (() -> Void)?
    var onConnectionFailure: (() -> Void)?

    init(clientID: String, host: String = "localhost", port: UInt16 = 1883) {
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqtt?.delegate = self
        mqtt?.keepAlive = 60
    }
    
    func connect() {
        mqtt?.connect()
    }
    
    func disconnect() {
        mqtt?.disconnect()
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

            // 키체인 MAC주소 로드 & 토픽 구독
            if let credentials = KeychainManager.shared.load() {
                let mac = credentials.mac
                // 연결된 필터 알림 수신
                subscribe(topic: "\(mac)/alarm")
                // 블랙리스트 & 화이트리스트
                subscribe(topic: "\(mac)/blacklist")
                subscribe(topic: "\(mac)/whitelist")
                subscribe(topic: "\(mac)/refreshBW")
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
        // Handle received message here
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print(("topic: \(success)"))
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("MQTT subscribed to topics: \(topics)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("MQTT unsubscribed from topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT ping!")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT pong~")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT disconnected: \(err?.localizedDescription ?? "")")
        onConnectionFailure?()
    }
}
