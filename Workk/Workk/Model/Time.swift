//
//  Time.swift
//  Workk
//
//  Created by Krzysztof Kogut on 05/11/2023.
//

import Foundation

struct Time {
    var hour: Int
    var min: Int
    var sec: Int
    var amPm: String = ""
    
    var hourString: String {
        hour < 10 ? "0\(hour)" : "\(hour)"
    }
    
    var minString: String {
        min < 10 ? "0\(min)" : "\(min)"
    }
    
    var secString: String {
        sec < 10 ? "0\(sec)" : "\(sec)"
    }
    
    var timeString: String {
        hourString + ":" + minString + ":" + secString
    }
    
    var hourMinString: String {
        hourString + ":" + minString
    }
}
