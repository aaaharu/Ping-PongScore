//
//  Helper.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/5/24.
//

import Foundation
import UIKit
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Font {
    static let dungGeunMo40 = Font.custom("DungGeunMo", size: 40)
}

