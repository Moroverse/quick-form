// ValueEditor.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

/// A protocol that defines a type capable of editing a value of a specific type.
///
/// `ValueEditor` is a simple yet powerful protocol in the QuickForm package that provides
/// a uniform interface for types that can edit values. It's typically used for form fields
/// and other UI components that need to modify and store values.
///
/// Conforming types must provide a `value` property that can be both get and set.
/// This property represents the current value being edited.
///
/// ## Example
///
/// Here's a basic example of a custom type conforming to `ValueEditor`:
///
/// ```swift
/// struct TextEditor: ValueEditor {
///     var value: String {
///         didSet {
///             // Perform any necessary actions when the value changes
///             updateUI()
///         }
///     }
///
///     init(initialValue: String = "") {
///         self.value = initialValue
///     }
///
///     private func updateUI() {
///         // Update the UI based on the new value
///     }
/// }
///
/// // Usage:
/// var editor = TextEditor(initialValue: "Hello")
/// editor.value = "Hello, World!"
/// ```
///
/// The `ValueEditor` protocol is often used in conjunction with other QuickForm components.
/// For example, it's commonly used with `FormFieldViewModel`:
///
/// ```swift
/// class CustomFieldViewModel: FormFieldViewModel<String>, ValueEditor {
///     // Additional custom logic...
/// }
///
/// let viewModel = CustomFieldViewModel(value: "Initial value")
/// viewModel.value = "New value"
/// ```
///
/// - Note: When implementing `ValueEditor`, consider whether you need to perform any
///   actions when the value changes, such as updating the UI or triggering validation.
public protocol ValueEditor<Value> {
    /// The type of value this editor can modify.
    associatedtype Value
    /// The current value being edited.
    var value: Value { get set }
}

public protocol ObservableValueEditor: ValueEditor {
    func onValueChanged(_ change: @escaping (Value) -> Void) -> Self
}
