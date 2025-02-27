// Binding+Unwrapped.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

import Foundation
import SwiftUI

/// An extension on `Binding` that provides a way to work with optional values as non-optional.
///
/// This extension adds an `unwrapped(_:)` method to `Binding<T?>`, allowing you to treat
/// an optional binding as a non-optional one with a default value. This is particularly
/// useful when working with SwiftUI views that don't natively support optional bindings.
///
/// ## Features
/// - Converts an optional binding to a non-optional one
/// - Provides a default value for when the binding's value is nil
/// - Preserves the two-way binding functionality
///
/// ## Example
///
/// ```swift
/// struct OptionalTextFieldExample: View {
///     @State private var optionalText: String? = nil
///
///     var body: some View {
///         TextField("Enter text", text: $optionalText.unwrapped(defaultValue: ""))
///             .textFieldStyle(RoundedBorderTextFieldStyle())
///
///         Text("Current value: \(optionalText ?? "nil")")
///     }
/// }
/// ```
///
/// In this example, the `TextField` uses a non-optional `String` binding,
/// but it's backed by an optional `String?` state variable. The `unwrapped(_:)`
/// method allows us to use the optional state with the non-optional `TextField`.
@MainActor
extension Binding {
    /// Unwraps an optional binding to create a non-optional binding.
    ///
    /// - Parameter defaultValue: The value to use when the binding's value is nil.
    /// - Returns: A new `Binding<T>` that wraps the optional value.
    ///
    /// - Note: This method will return the actual value if it's not nil,
    ///         otherwise it will return the provided default value.
    func unwrapped<T>(defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
