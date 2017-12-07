//
//  Tsuchi.swift
//  Tsuchi
//
//  Created by kazuya-miura on 2017/12/05.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging

public class Tsuchi<T: PushNotificationProtocol>: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    public var didRefreshRegistrationTokenActionBlock: ((String) -> Void)?
    public var didReceiveRemoteNotificationActionBlock: ((T) -> Void)?
    public var didOpenApplicationFromNotificationActionBlock: ((T) -> Void)?
    public var isShowingBanner: Bool = false

    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: .UIApplicationDidEnterBackground, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }

    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        self.connectToFcm()
    }

    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false
        debugPrint("[NotificationManager] Disconnected from FCM")
    }

    func connectToFcm() {
        guard Messaging.messaging().fcmToken != nil else {
            return
        }
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    public func register(completion: ((Bool) -> Void)?) {
        if !UIApplication.shared.isRegisteredForRemoteNotifications {
            requestAuthorization { (granted, _) in
                completion?(granted)
            }
            return
        }
        completion?(true)
    }

    public func unregister(completion: (() -> Void)?) {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
        completion?()
    }

    func requestAuthorization(block: @escaping ((Bool, Error?) -> Void) = { _, _ in }) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { granted, error in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                block(granted, error)
            }
        })
    }

    //MARK: UNUserNotificationDelegate
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard notification.request.trigger is UNPushNotificationTrigger else { completionHandler([]); return }
        let userInfo: [AnyHashable: Any] = notification.request.content.userInfo
        debugPrint("[NotificationManager] willPresent Message ID: \(userInfo["gcm.message_id"] as Any)")
        debugPrint("[NotificationManager] ", userInfo)
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            let payload: T = try JSONDecoder().decode(T.self, from: data)
            if isShowingBanner {
                completionHandler([.alert, .badge, .sound])
            } else {
                completionHandler([.badge, .sound])
            }
            didReceiveRemoteNotificationActionBlock?(payload)
        } catch let error {
            print(error)
        }
    }

    // open notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.notification.request.trigger is UNPushNotificationTrigger else { completionHandler(); return }
        debugPrint("[NotificationManager] didReceive response ID: \(response)")
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            let payload: T = try JSONDecoder().decode(T.self, from: data)
            completionHandler()
            didOpenApplicationFromNotificationActionBlock?(payload)
        } catch let error {
            print(error)
        }

    }

    //MARK: MessagingDelegate
    public func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        debugPrint("[NotificationManager] didRefreshRegistrationToken", fcmToken)
        connectToFcm()
        didRefreshRegistrationTokenActionBlock?(fcmToken)
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        connectToFcm()
        didRefreshRegistrationTokenActionBlock?(fcmToken)
    }

    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        debugPrint(remoteMessage.appData, "hige")
    }

    public func application(received remoteMessage: MessagingRemoteMessage) {
        debugPrint(remoteMessage.appData, "hoge")
    }
}
