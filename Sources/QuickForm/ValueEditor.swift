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

/// A protocol that extends `ValueEditor` to provide observation capabilities.
///
/// `ObservableValueEditor` adds the ability to register callbacks that are triggered
/// when the value changes, enabling reactive programming patterns with form fields.
/// This is particularly useful for updating UI components, triggering validation,
/// or propagating changes to other parts of your application.
///
/// Conforming types must implement the `onValueChanged` method that registers a callback
/// to be invoked whenever the value changes.
///
/// ## Example
///
/// ```swift
/// class ReactiveFieldViewModel<T>: ObservableValueEditor {
///     var value: T {
///         didSet {
///             // Notify subscribers about the change
///             notifySubscribers(value)
///         }
///     }
///
///     private var subscribers: [(T) -> Void] = []
///
///     init(value: T) {
///         self.value = value
///     }
///
///     @discardableResult
///     func onValueChanged(_ change: @escaping (T) -> Void) -> Self {
///         subscribers.append(change)
///         return self
///     }
///
///     private func notifySubscribers(_ newValue: T) {
///         subscribers.forEach { $0(newValue) }
///     }
/// }
///
/// // Usage:
/// let field = ReactiveFieldViewModel(value: 0)
/// field.onValueChanged { newValue in
///     print("Value changed to: \(newValue)")
/// }
/// field.value = 42 // Prints: "Value changed to: 42"
/// ```
public protocol ObservableValueEditor: ValueEditor {
    /// Registers a callback to be invoked when the value changes.
    ///
    /// - Parameter change: A closure that will be called whenever the value changes,
    ///   with the new value as its parameter.
    /// - Returns: The editor instance for method chaining.
    func onValueChanged(_ change: @escaping (Value) -> Void) -> Self
}
