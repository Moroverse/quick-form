// Binding+Unwrapped.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

import Foundation
import SwiftUI

extension Binding {
    func unwrapped<T>(defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
