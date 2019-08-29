//
//  ConstGlobal.swift
//  SunibCurhat
//
//  Created by Rangga Leo on 04/08/19.
//  Copyright © 2019 Rangga Leo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct ConstGlobal {
    static let AdMOB_APP_ID: String = "ca-app-pub-9947251997620985~4316262809"
    static let AdMOB_UNIT_ID_TEST_BANNER: String = "ca-app-pub-3940256099942544/2934735716"
    static let AdMOB_UNIT_ID_1: String = "ca-app-pub-9947251997620985/5054629407"
    
    static let MINIMUM_TEXT: Int = 5
}

struct RepoMemory {
    static var token: String? {
        didSet {
            NotificationCenter.default.post(name: .tokenIsChanged, object: nil)
        }
    }
    
    static var user_firebase: User? {
        didSet {
            NotificationCenter.default.post(name: .userFirebaseIsChanged, object: nil)
        }
    }
    
    static var pendingFunction: (() -> Void)?
    static var user_name: String?
    static let device_id: String = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
}
