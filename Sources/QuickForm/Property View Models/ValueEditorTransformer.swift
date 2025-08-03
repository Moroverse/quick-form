// ValueEditorTransformer.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-02 09:52 GMT.

import Observation

/// A transformer that creates a bidirectional connection between a source value editor
/// and a transformed representation.
///
/// `ValueEditorTransformer` enables you to work with different representations of the same
/// underlying data while maintaining bidirectional synchronization. When the source editor
/// changes, the transformer's value is updated automatically. Similarly, when the
/// transformer's value changes, the source editor is updated.
///
/// Unlike ``ModelTransformer``, this class is Observable and provides change notification
/// through the Observation framework.
///
/// ## Examples
///
/// ### String to Boolean Transformation
///
/// ```swift
/// // Create a text field view model
/// let textField = FormFieldViewModel(value: "true")
///
/// // Transform between string and boolean
/// let booleanTransformer = ValueEditorTransformer(
///     original: textField,
///     transformFromSource: { $0.lowercased() == "true" },
///     transformToSource: { $0 ? "true" : "false" }
/// )
///
/// // Use the transformer in a toggle field
/// FormToggleField(booleanTransformer)
/// ```
///
/// ### Number Formatting
///
/// ```swift
/// // Create a numeric field
/// let priceField = FormFieldViewModel(value: 29.99)
///
/// // Create a transformer that formats the price as currency
/// let formattedPrice = priceField.map(
///     transformFromSource: { "$\(String(format: "%.2f", $0))" },
///     transformToSource: { Double($0.dropFirst()) ?? 0.0 }
/// )
///
/// // Use the transformed value in a text field
/// FormTextField(formattedPrice)
/// ```
@Observable
public final class ValueEditorTransformer<SourceEditor, Transformed>: ObservableValueEditor
    where SourceEditor: ObservableValueEditor {
    @ObservationIgnored
    private var settingValue = false

    /// The transformed value.
    ///
    /// When this value is set, the source editor's value is updated using `transformToSource`.
    /// Changes to this property trigger observation updates in SwiftUI views.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a transformer between a string field and boolean representation
    /// let transformer = ValueEditorTransformer(
    ///     original: stringField,
    ///     transformFromSource: { $0 == "yes" },
    ///     transformToSource: { $0 ? "yes" : "no" }
    /// )
    ///
    /// // Read the transformed value
    /// if transformer.value {
    ///     print("Value is affirmative")
    /// }
    ///
    /// // Update the value, which also updates the source field
    /// transformer.value = false // Sets source to "no"
    /// ```
    public var value: Transformed {
        didSet {
            if settingValue == true { return }
            if let oldH = oldValue as? AnyHashable,
               let newH = value as? AnyHashable,
               oldH == newH {
                return
            }
            settingValue = true
            sourceEditor.value = transformToSource(value)
            settingValue = false
            dispatcher.publish(value)
        }
    }

    /// Registers a callback to be invoked when the transformed value changes.
    ///
    /// This method allows you to respond to changes in the transformed value, whether they
    /// originated from changes to the source editor or from direct assignments to the
    /// transformer's value property.
    ///
    /// - Parameter change: A closure that will be called whenever the value changes,
    ///   with the new value as its parameter.
    /// - Returns: A ``Subscription`` that can be used to unsubscribe when the notification
    ///   is no longer needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let subscription = priceTransformer.onValueChanged { newPrice in
    ///     // Update tax calculation when price changes
    ///     taxField.value = calculateTax(newPrice)
    /// }
    ///
    /// // Later, when you no longer need the notification
    /// subscription.unsubscribe()
    /// ```
    ///
    /// - SeeAlso: ``Subscription``, ``Dispatcher``
    @discardableResult
    public func onValueChanged(_ change: @escaping (Transformed) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }

    /// The source editor that provides the original value.
    ///
    /// This is the editor that is being transformed. Changes to this editor's value
    /// are automatically reflected in the transformer's value through the
    /// `transformFromSource` function.
    @ObservationIgnored
    public private(set) var sourceEditor: SourceEditor

    /// Function that converts from the source value type to the transformed value type.
    private let transformFromSource: (SourceEditor.Value) -> Transformed

    /// Function that converts from the transformed value type back to the source value type.
    private let transformToSource: (Transformed) -> SourceEditor.Value

    /// The dispatcher used to notify subscribers of value changes.
    private let dispatcher: Dispatcher

    /// Creates a new value editor transformer that connects a source editor with a transformed representation.
    ///
    /// This initializer sets up the bidirectional connection between the source editor and
    /// the transformed representation. Changes to either side are automatically propagated
    /// to the other side.
    ///
    /// - Parameters:
    ///   - original: The source editor containing the original value
    ///   - transformFromSource: A closure that transforms from the source value type to the destination value type
    ///   - transformToSource: A closure that transforms from the destination value type back to the source value type
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Transform a decimal field to a percentage representation
    /// let decimalField = FormFieldViewModel(value: 0.75)
    ///
    /// let percentageTransformer = ValueEditorTransformer(
    ///     original: decimalField,
    ///     transformFromSource: { $0 * 100 },  // Convert 0.75 to 75
    ///     transformToSource: { $0 / 100 }     // Convert 75 to 0.75
    /// )
    ///
    /// // Use in a form component
    /// FormStepperField(percentageTransformer, range: 0...100)
    /// ```
    public init(
        original: SourceEditor,
        transformFromSource: @escaping (SourceEditor.Value) -> Transformed,
        transformToSource: @escaping (Transformed) -> SourceEditor.Value
    ) {
        sourceEditor = original
        self.transformToSource = transformToSource
        self.transformFromSource = transformFromSource
        value = transformFromSource(original.value)
        dispatcher = Dispatcher()

        _ = sourceEditor.onValueChanged { [weak self] in
            if self?.settingValue == true { return }
            self?.settingValue = true
            let transformed = transformFromSource($0)
            self?.value = transformed
            self?.dispatcher.publish(transformed)
            self?.settingValue = false
        }
    }
}

public extension ValueEditor {
    /// Creates a transformer that maps the editor's value to a different type.
    ///
    /// This method provides a convenient way to create a ``ValueEditorTransformer`` from
    /// any value editor, allowing you to work with a transformed representation of the
    /// original value while maintaining bidirectional synchronization.
    ///
    /// - Parameters:
    ///   - transformFromSource: A closure that transforms from the source value type to the transformed value type
    ///   - transformToSource: A closure that transforms from the transformed value type back to the source value type
    /// - Returns: A new ``ValueEditorTransformer`` that provides the transformed representation
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Format a date field as a string
    /// let dateField = FormFieldViewModel(value: Date())
    ///
    /// // Map the Date to a formatted String
    /// let dateStringEditor = dateField.map(
    ///     transformFromSource: { date in
    ///         let formatter = DateFormatter()
    ///         formatter.dateStyle = .medium
    ///         return formatter.string(from: date)
    ///     },
    ///     transformToSource: { string in
    ///         let formatter = DateFormatter()
    ///         formatter.dateStyle = .medium
    ///         return formatter.date(from: string) ?? Date()
    ///     }
    /// )
    ///
    /// // Use the string representation in a text field
    /// FormTextField(dateStringEditor)
    /// ```
    ///
    /// - SeeAlso: ``ValueEditorTransformer``
    func map<TransformedValue>(
        transformFromSource: @escaping (Value) -> TransformedValue,
        transformToSource: @escaping (TransformedValue) -> Value
    ) -> ValueEditorTransformer<Self, TransformedValue> {
        ValueEditorTransformer(
            original: self,
            transformFromSource: transformFromSource,
            transformToSource: transformToSource
        )
    }
}
