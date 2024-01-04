//
//  Helper.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/5/24.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
