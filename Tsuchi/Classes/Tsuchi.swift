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

public class Tsuchi: NSObject {
    private struct Container<T: PushNotificationPayload>: SubscribeContainer {
        let handler: (Result<(T, NotificationMode), Error>) -> Void

        func parse(_ json: [AnyHashable: Any], mode: NotificationMode) {
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                let notification = try JSONDecoder().decode(T.self, from: data)
                handler(.success((notification, mode)))
            } catch let error {
                handler(.failure(error))
            }
        }
    }

    private struct AnyContainer: SubscribeContainer {
        let base: SubscribeContainer

        func parse(_ json: [AnyHashable: Any], mode: NotificationMode) {
            base.parse(json, mode: mode)
        }
    }

    public static let shared = Tsuchi()
    private var container: AnyContainer?
    public var didRefreshRegistrationTokenActionBlock: ((String) -> Void)?
    @available(*, deprecated, message: "Use `notificationPresentationOptions` instead.")
    public var showsNotificationBannerOnPresenting: Bool = true {
        didSet {
            notificationPresentationOptions = showsNotificationBannerOnPresenting ? [.alert, .badge, .sound] : [.badge, .sound]
        }
    }
    public var notificationPresentationOptions: UNNotificationPresentationOptions = [.alert, .badge, .sound]

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    public func subscribe<T: PushNotificationPayload>(_ type: T.Type, handler: @escaping (Result<(T, NotificationMode), Error>) -> Void) {
        self.container = AnyContainer(base: Container<T>(handler: handler))
    }

    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        self.connectToFcm()
    }

    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false
        debugPrint("[Tsuchi] Disconnected from FCM")
    }

    func connectToFcm() {
        guard Messaging.messaging().fcmToken != nil else {
            return
        }
        Messaging.messaging().shouldEstablishDirectChannel = true
    }

    public func register(completion: ((Bool) -> Void)?) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                completion?(true)
                return
            }
            if settings.notificationCenterSetting == .enabled {
                completion?(true)
                return
            }
            self.requestAuthorization { (granted, _) in
                completion?(granted)
            }
        }
    }

    public func unregister(completion: (() -> Void)?) {
        UIApplication.shared.unregisterForRemoteNotifications()
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

    public func subscribe(toTopic topic: TopicType) {
        Messaging.messaging().subscribe(toTopic: topic.rawValue)
    }

    public func unsubscribe(fromTopic topic: TopicType) {
        Messaging.messaging().unsubscribe(fromTopic: topic.rawValue)
    }
}

extension Tsuchi: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard notification.request.trigger is UNPushNotificationTrigger else { completionHandler([]); return }
        let userInfo: [AnyHashable: Any] = notification.request.content.userInfo
        debugPrint("[Tsuchi] willPresent Message ID: \(userInfo["gcm.message_id"] as Any)")
        debugPrint("[Tsuchi] ", userInfo)
        container?.base.parse(userInfo, mode: .willPresent)
        completionHandler(notificationPresentationOptions)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.notification.request.trigger is UNPushNotificationTrigger else { completionHandler(); return }
        debugPrint("[Tsuchi] didReceive response ID: \(response)")
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        container?.base.parse(userInfo, mode: .didReceive)
        completionHandler()
    }
}

extension Tsuchi: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        debugPrint("[Tsuchi] didRefreshRegistrationToken", fcmToken)
        connectToFcm()
        didRefreshRegistrationTokenActionBlock?(fcmToken)
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        debugPrint("[Tsuchi] didReceiveRegistrationToken", fcmToken)
        connectToFcm()
        didRefreshRegistrationTokenActionBlock?(fcmToken)
    }

    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        debugPrint(remoteMessage.appData)
    }

    public func application(received remoteMessage: MessagingRemoteMessage) {
        debugPrint(remoteMessage.appData)
    }
}

