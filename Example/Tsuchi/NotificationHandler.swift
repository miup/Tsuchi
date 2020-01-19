//
//  NotificationHandler.swift
//  Tsuchi_Example
//
//  Created by kazuya-miura on 2017/12/07.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Tsuchi

struct PushNotification: PushNotificationPayload {
    let hoge: String
    let hige: String
    let aps: APS?
}

enum Topic: String, TopicType {
    case news
}

class NotificationHandler {
    static let shared = NotificationHandler()

    private init() {
        // initialize your tsuchi settings
        Tsuchi.shared.notificationPresentationOptions = [.alert, .badge, .sound]

        Tsuchi.shared.didRefreshRegistrationTokenActionBlock = { token in
            // save token to your Database
        }

        Tsuchi.shared.subscribe(PushNotification.self) { result in
            switch result {
            case let .success((payload, mode)):
                print("reiceived: \(payload), mode: \(mode)")
            case let .failure(error):
                print("error: \(error)")
            }
        }
    }

    func register() {
        Tsuchi.shared.register { granted in
            if granted {
                print("success registration")
            } else {
                print("failure registration")
            }
        }
    }

    func unregister() {
        Tsuchi.shared.unregister {
            print("unregister")
        }
    }

    func subscribe(topic: Topic) {
        Tsuchi.shared.subscribe(toTopic: topic)
    }

    func unsubscribe(topic: Topic) {
        Tsuchi.shared.unsubscribe(fromTopic: topic)
    }
}
