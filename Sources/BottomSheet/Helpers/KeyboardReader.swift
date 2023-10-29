//
//  KeyboardReader.swift
//  
//
//  Created by Wouter van de Kamp on 28/10/2023.
//

import Combine
import UIKit

protocol KeyboardReader {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReader {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
