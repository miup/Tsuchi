//
//  PushNotificationPayload.swift
//  Tsuchi
//
//  Created by kazuya-miura on 2017/12/07.
//

import Foundation

public protocol PushNotificationPayload: Decodable {
    var aps: APS? { get }
}

public struct APS: Decodable {
    public struct Alert: Decodable {
        public let body: String?
        public let title: String?
    }

    public let alert: Alert?
    public let badge: Int?
    public let sound: String?

    enum CodingKeys: String, CodingKey {
        case alert
        case badge
        case sound
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let body = try? container.decodeIfPresent(String.self, forKey: .alert) {
            alert = Alert(body: body, title: nil)
        } else {
            alert = try container.decode(Alert.self, forKey: .alert)
        }
        badge = try container.decodeIfPresent(Int.self, forKey: .badge)
        sound = try container.decodeIfPresent(String.self, forKey: .sound)
    }
}
