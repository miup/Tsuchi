//
//  NotificationHandler.swift
//  Tsuchi_Example
//
//  Created by kazuya-miura on 2017/12/07.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Tsuchi

struct PushNotification: PushNotificationProtocol {
    let hoge: String
    let hige: String
    var aps: APS?
}

class NotificationHandler {
    static let shared = NotificationHandler()
    private let tsuchi: Tsuchi<PushNotification> = Tsuchi()

    private init() {
        // initialize your tsuchi settings
        tsuchi.isShowingBanner = true

        tsuchi.didRefreshRegistrationTokenActionBlock = { token in
            print(token)
        }

        tsuchi.didOpenApplicationFromNotificationActionBlock = { pushNotification in
            print(pushNotification)
        }

        tsuchi.didReceiveRemoteNotificationActionBlock = { pushNotification in
            print(pushNotification)
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
