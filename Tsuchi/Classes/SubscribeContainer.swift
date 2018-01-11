//
//  SubscribeContainer.swift
//
//  Created by suguru-kishimoto on 2018/01/11.
//

import Foundation

public protocol SubscribeContainer {
    func parse(_ json: [AnyHashable: Any], mode: NotificationMode)
}
