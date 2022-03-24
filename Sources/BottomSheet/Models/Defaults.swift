//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 21/03/2022.
//

import Foundation

struct BottomSheetDefaults {
    struct Animation {
        static var mass: Double =  1.2
        static var stiffness: Double = 200
        static var damping: Double = 25
    }
    
    struct Interaction {
        static var threshold: Double = 1.8
    }
}
