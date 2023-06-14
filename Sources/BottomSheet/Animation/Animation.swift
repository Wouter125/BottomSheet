//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 26/11/2022.
//

import Foundation

public struct SheetAnimation {
    var mass: Double
    var stiffness: Double
    var damping: Double
    
    public init(mass: Double, stiffness: Double, damping: Double) {
        self.mass = mass
        self.stiffness = stiffness
        self.damping = damping
    }
}
