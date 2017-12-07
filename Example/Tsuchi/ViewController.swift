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
        NotificationHandler.shared.register()
    }

}
