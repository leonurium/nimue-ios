//
//  Logger.swift
//  SunibCurhat
//
//  Created by Rangga Leo on 04/08/19.
//  Copyright © 2019 Rangga Leo. All rights reserved.
//

import Foundation
import StoreKit

func print_r(title: String, message: Any?) {
    print("=====[START \(title.uppercased())]=====")
    print(message ?? "nothing")
    print("=====[END OF \(title.uppercased())=====]")
}

func checkRange(_ range: NSRange, contain index: Int) -> Bool {
    return index > range.location && index < range.location + range.length
}

func requestReviewAppStore() {
    let timesAccess = UDHelpers.shared.getInt(key: .counterUserAccessApp)
    
    if timesAccess == ConstGlobal.TIMES_REQUEST_REVIEW {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
        UDHelpers.shared.set(value: timesAccess + 1, key: .counterUserAccessApp)
    
    } else {
        UDHelpers.shared.set(value: timesAccess + 1, key: .counterUserAccessApp)
    }
}
