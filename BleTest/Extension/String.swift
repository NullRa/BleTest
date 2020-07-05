//
//  String.swift
//  BleTest
//
//  Created by Jay on 2020/7/4.
//  Copyright © 2020 Null. All rights reserved.
//

import Foundation

// +Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
