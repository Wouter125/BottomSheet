//
//  File.swift
//  
//
//  Created by Wouter van de Kamp on 20/03/2022.
//

import Foundation

public enum PositionType {
    case absolute
    case relative
}

public struct PositionModel {
    static var type: PositionType = .relative
}
