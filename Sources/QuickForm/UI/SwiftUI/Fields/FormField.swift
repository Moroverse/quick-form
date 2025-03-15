// FormField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-06 06:44 GMT.

// FormField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-06 12:00 GMT.

import Foundation
import QuickForm
import SwiftUI

/// A property wrapper that connects a value with a `FormFieldViewModel`.
///
/// `@FormField` provides a convenient way to create form fields that automatically
/// synchronize with their underlying data. The property wrapper manages both the
/// value and a corresponding `FormFieldViewModel` that can be used with SwiftUI form controls.
///
/// ## Example
///
/// ```swift
/// struct PersonForm {
///     @FormField(title: "Name", placeholder: "Enter your name")
///     var name: String = ""
///
///     @FormField(title: "Age", validation: .of { value in
///         value >= 18 ? .success : .failure("Must be at least 18")
///     })
///     var age: Int = 0
/// }
/// ```
@propertyWrapper
public class FormField<Value> {
    private var _value: Value
    private var _viewModel: FormFieldViewModel<Value>
    private var isUpdating = false

    /// Creates a FormField with the specified initial value and configuration options.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value for the field
    ///   - title: The title displayed for this field
    ///   - placeholder: Optional placeholder text
    ///   - isReadOnly: Whether the field is read-only
    ///   - validation: Optional validation rule
    public init(
        wrappedValue: Value,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Value>? = nil
    ) {
        _value = wrappedValue
        _viewModel = FormFieldViewModel(
            value: wrappedValue,
            title: title,
            placeholder: placeholder,
            isReadOnly: isReadOnly,
            validation: validation
        )

        // Set up synchronization from view model to wrapped value
        _viewModel.onValueChanged { [weak self] newValue in
            guard let self, !self.isUpdating else { return }

            isUpdating = true
            _value = newValue
            isUpdating = false
        }
    }

    /// The wrapped value - the actual data being edited
    public var wrappedValue: Value {
        get { _value }
        set {
            guard !isUpdating else { return }

            _value = newValue

            // Synchronize to view model
            isUpdating = true
            _viewModel.value = newValue
            isUpdating = false
        }
    }

    /// The projected value - provides access to the FormFieldViewModel
    public var projectedValue: FormFieldViewModel<Value> {
        get { _viewModel }
        set { _viewModel = newValue }
    }
}

// Convenience extension for DefaultValueProvider types
public extension FormField where Value: DefaultValueProvider {
    /// Creates a FormField with default value and specified configuration options.
    ///
    /// - Parameters:
    ///   - type: The type of value to create
    ///   - title: The title displayed for this field
    ///   - placeholder: Optional placeholder text
    ///   - isReadOnly: Whether the field is read-only
    ///   - validation: Optional validation rule
    convenience init(
        type: Value.Type,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Value>? = nil
    ) {
        self.init(
            wrappedValue: Value.defaultValue,
            title: title,
            placeholder: placeholder,
            isReadOnly: isReadOnly,
            validation: validation
        )
    }
}
