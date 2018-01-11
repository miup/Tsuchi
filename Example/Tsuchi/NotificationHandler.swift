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
    var aps: APS?
}

class NotificationHandler {
    static let shared = NotificationHandler()
    private let tsuchi = Tsuchi.shared

    private init() {
        // initialize your tsuchi settings
        tsuchi.showsNotificationBannerOnPresenting = true

        tsuchi.didRefreshRegistrationTokenActionBlock = { token in
            print(token)
        }

        tsuchi.subscribe(PushNotification.self) { result in
            switch result {
            case let .success((payload, mode)):
                print("reiceived: \(payload), mode: \(mode)")
            case let .failure(error):
                print("error: \(error)")
            }
        }
    }

    func register() {
        tsuchi.register { granted in
            if granted {
                print("success")
            } else {
                print("failure")
            }
        }
    }

    func unregister() {
        tsuchi.unregister {
            print("unregister")
        }
    }

}
