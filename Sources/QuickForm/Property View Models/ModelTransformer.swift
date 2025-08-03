// ModelTransformer.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-18 03:38 GMT.

import Observation

/// A value editor that transforms between two different value editor types.
///
/// `ModelTransformer` connects two value editors and provides bidirectional
/// transformation between their values. This is useful when you need to work
/// with different representations of the same underlying data without duplicating logic
/// or manually synchronizing values.
///
/// ## Features
/// - Transforms values bidirectionally between two editors
/// - Maintains synchronized state between both editors
/// - Works with any types that implement the ``ValueEditor`` protocol
/// - Updates both source and destination values automatically
///
/// ## Examples
///
/// ### String-Integer Transformation
///
/// ```swift
/// // Transform between a string field and an integer field
/// let stringField = FormFieldViewModel(value: "42")
/// let intField = FormFieldViewModel(value: 0)
///
/// let transformer = ModelTransformer(
///     original: stringField,
///     new: intField,
///     mapFrom: { Int($0) ?? 0 },
///     mapTo: { String($0) }
/// )
///
/// // Reading from transformer uses the mapFrom function
/// print(transformer.value) // Outputs: 42
///
/// // Setting transformer.value updates both editors
/// transformer.value = 100
/// print(stringField.value) // Outputs: "100"
/// print(intField.value)    // Outputs: 100
/// ```
///
/// ### Custom Type Conversion
///
/// ```swift
/// // A Bool to custom string representation
/// let boolField = FormFieldViewModel(value: true)
/// let textField = FormFieldViewModel(value: "")
///
/// let transformer = ModelTransformer(
///     original: boolField,
///     new: textField,
///     mapFrom: { $0 ? "Yes" : "No" },
///     mapTo: { $0.lowercased() == "yes" }
/// )
///
/// // Use the transformer in a UI component
/// FormTextField(transformer.new)
///     .onChange(of: transformer.value) { _, newValue in
///         print("Value changed to: \(newValue)")
///     }
/// ```
///
/// - SeeAlso: ``ValueEditor``, ``FormFieldViewModel``
public final class ModelTransformer<SourceEditor, DestinationEditor>: ValueEditor
    where SourceEditor: ValueEditor, DestinationEditor: ValueEditor {
    /// The transformed value.
    ///
    /// When getting this value, it transforms the original editor's value using `mapFrom`.
    /// When setting this value, it updates both the destination editor and transforms
    /// it back to update the original editor using `mapTo`.
    ///
    /// The value access flow works as follows:
    /// - **Get**: source value → mapFrom → destination value → return
    /// - **Set**: new value → update destination → mapTo → update source
    public var value: DestinationEditor.Value {
        get {
            new.value = mapFrom(original.value)
            return new.value
        }
        set {
            if let oldH = newValue as? AnyHashable,
               let newH = value as? AnyHashable,
               oldH == newH {
                return
            }
            new.value = newValue
            original.value = mapTo(new.value)
        }
    }

    /// The source editor that provides the original value.
    ///
    /// This is the primary data source that gets transformed into the destination format.
    /// When the destination value changes, this source is updated using the `mapTo` function.
    public private(set) var original: SourceEditor

    /// The destination editor that represents the transformed value.
    ///
    /// This editor holds the transformed representation of the source value.
    /// When accessed through the transformer, its value is always computed from the
    /// source using the `mapFrom` function.
    public private(set) var new: DestinationEditor

    /// The function that transforms from source type to destination type.
    private let mapFrom: (SourceEditor.Value) -> DestinationEditor.Value

    /// The function that transforms from destination type back to source type.
    private let mapTo: (DestinationEditor.Value) -> SourceEditor.Value

    /// Creates a new model transformer that connects two value editors with bidirectional transformations.
    ///
    /// This initializer sets up the transformation pipeline between the source and destination editors.
    /// The `mapFrom` and `mapTo` functions should be logical inverses of each other to ensure
    /// data consistency when transforming back and forth.
    ///
    /// - Parameters:
    ///   - original: The source editor containing the original value
    ///   - new: The destination editor that will contain the transformed value
    ///   - mapFrom: A closure that transforms from the source value type to the destination value type
    ///   - mapTo: A closure that transforms from the destination value type back to the source value type
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Transform between a Date and its string representation
    /// let dateField = FormFieldViewModel(value: Date())
    /// let stringField = FormFieldViewModel(type: String.self)
    ///
    /// let dateTransformer = ModelTransformer(
    ///     original: dateField,
    ///     new: stringField,
    ///     mapFrom: { date in
    ///         let formatter = DateFormatter()
    ///         formatter.dateStyle = .medium
    ///         return formatter.string(from: date)
    ///     },
    ///     mapTo: { string in
    ///         let formatter = DateFormatter()
    ///         formatter.dateStyle = .medium
    ///         return formatter.date(from: string) ?? Date()
    ///     }
    /// )
    /// ```
    public init(
        original: SourceEditor,
        new: DestinationEditor,
        mapFrom: @escaping (SourceEditor.Value) -> DestinationEditor.Value,
        mapTo: @escaping (DestinationEditor.Value) -> SourceEditor.Value
    ) {
        self.original = original
        self.new = new
        self.mapTo = mapTo
        self.mapFrom = mapFrom
    }
}
