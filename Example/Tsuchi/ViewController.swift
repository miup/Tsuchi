//
//  ViewController.swift
//  Tsuchi
//
//  Created by miup on 12/01/2017.
//  Copyright (c) 2017 miup. All rights reserved.
//

import UIKit
import Tsuchi

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapRegister(_ sender: Any) {
        NotificationHandler.shared.register()
    }

    @IBAction func didTapSubscribeNewsTopic(_ sender: Any) {
        NotificationHandler.shared.subscribe(topic: .news)
    }

    @IBAction func didTapUnsubscribeNewsTopic(_ sender: Any) {
        NotificationHandler.shared.unsubscribe(topic: .news)
    }

    @IBAction func didTapUnregister(_ sender: Any) {
        NotificationHandler.shared.unregister()
    }
}
