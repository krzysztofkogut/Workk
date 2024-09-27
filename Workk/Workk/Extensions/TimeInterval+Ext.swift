//
//  TimeInterval+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/01/2024.
//

import Foundation

extension TimeInterval {
    var hours: Int {
        let ti = Int(self)
        return ti / 3600
    }
    
    var minutes: Int {
        let ti = Int(self)
        return (ti / 60) % 60
    }
    
    var seconds: Int {
        let ti = Int(self)
        return ti % 60
    }
    
    var hourString: String {
        hours < 10 ? "0\(hours)" : "\(hours)"
    }
    
    var minString: String {
        minutes < 10 ? "0\(minutes)" : "\(minutes)"
    }
    
    var timeString: String {
        hourString + ":" + minString + ":" + secString
    }
    
    var hourMinString: String {
        hourString + ":" + minString
    }
    
    var secString: String {
        seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
}
