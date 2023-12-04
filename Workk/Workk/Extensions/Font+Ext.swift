//
//  Font+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 12/11/2023.
//

import SwiftUI

extension Font {
    static func latoBold(size: CGFloat) -> Font {
        return Font.custom("Lato-Bold", size: size)
    }
    
    static func latoBlack(size: CGFloat) -> Font {
        return Font.custom("Lato-Black", size: size)
    }
    
    static func latoLight(size: CGFloat) -> Font {
        return Font.custom("Lato-Light", size: size)
    }
    
    static func latoRegular(size: CGFloat) -> Font {
        return Font.custom("Lato-Regular", size: size)
    }
        
    static func nunitoSemiBold(size: CGFloat) -> Font {
        return Font.custom("Nunito-SemiBold", size: size)
    }
    
    static func nunitoBold(size: CGFloat) -> Font {
        return Font.custom("Nunito-Bold", size: size)
    }
    
    static func nunitoBlack(size: CGFloat) -> Font {
        return Font.custom("Nunito-Black", size: size)
    }
    
    static func nunitoRegular(size: CGFloat) -> Font {
        return Font.custom("Nunito-Regular", size: size)
    }
}
