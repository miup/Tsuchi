# Tsuchi
Tsuchi is awesome Firebase Cloud Messaging wrapper.  
You can handle FCM easily and type-safely.  

[![CI Status](http://img.shields.io/travis/miup/Tsuchi.svg?style=flat)](https://travis-ci.org/miup/Tsuchi)
[![Version](https://img.shields.io/cocoapods/v/Tsuchi.svg?style=flat)](http://cocoapods.org/pods/Tsuchi)
[![License](https://img.shields.io/cocoapods/l/Tsuchi.svg?style=flat)](http://cocoapods.org/pods/Tsuchi)
[![Platform](https://img.shields.io/cocoapods/p/Tsuchi.svg?style=flat)](http://cocoapods.org/pods/Tsuchi)

## Usage
### Register/Unregister Notification
```swift
User.login {
    // register remote notification (show dialog if user not determined about notification permission.)
    Tsuchi.shared.register { authorized in
        //...
    }
}

User.logout {
    Tsuchi.shared.unregister { authorized in
        //...
    }
}
```

### Subscribe Push Notification

- 1. Create Payload Model (must conform to `PushNotificationPayload`)

```swift
struct FCMNotificationPayload: PushNotificationPayload {
    let eventName: String?
    let eventType: EventType?
    var aps: APS?
}

```

- 2. call `Tsuchi.subscibe(_:completion)`

```swift
Tsuchi.shared.subscribe(FCMNotificationPayload.self) { result in
    switch result {
    case .success(let (notification, mode)):
        print(notification.name, mode)
    case .failure(let error):
        print(error)
    }
}
```

### Subscribe/UnSubscribe Topic
```swift
public enum AppTopic: String, TopicType {
    case owner
    case member
}

// Subscribe topic
Tsuchi.shared.subscribe(toTopic: AppTopic.owner)

// Unsubscribe topic
Tsuchi.shared.unsubscribe(fromTopic: AppTopic.owner)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Tsuchi is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Tsuchi'
```

## Author

miup, contact@miup.blue

## License

Tsuchi is available under the MIT license. See the LICENSE file for more info.
