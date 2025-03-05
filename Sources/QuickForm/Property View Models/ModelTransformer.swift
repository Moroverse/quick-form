// ModelTransformer.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-18 04:54 GMT.

import Observation

/// A value editor that transforms between two different value editor types.
///
/// `ModelTransformer` connects two value editors and provides bidirectional
/// transformation between their values. This is useful when you need to work
/// with different representations of the same underlying data.
///
/// Example usage:
/// ```
/// // Transform between a string field and an integer field
/// let transformer = ModelTransformer(
///     original: stringField,
///     new: intField,
///     mapFrom: { Int($0) ?? 0 },
///     mapTo: { String($0) }
/// )
/// ```
public final class ModelTransformer<SourceEditor, DestinationEditor>: ValueEditor
    where SourceEditor: ValueEditor, DestinationEditor: ValueEditor {
    /// The transformed value.
    ///
    /// When getting this value, it transforms the original editor's value using `mapFrom`.
    /// When setting this value, it updates both the destination editor and transforms
    /// it back to update the original editor using `mapTo`.
    public var value: DestinationEditor.Value {
        get {
            new.value = mapFrom(original.value)
            return new.value
        }
        set {
            new.value = newValue
            original.value = mapTo(new.value)
        }
    }

    /// The source editor that provides the original value.
    public private(set) var original: SourceEditor
    /// The destination editor that represents the transformed value.
    public private(set) var new: DestinationEditor

    private let mapFrom: (SourceEditor.Value) -> DestinationEditor.Value
    private let mapTo: (DestinationEditor.Value) -> SourceEditor.Value

    /// Creates a new model transformer that connects two value editors with bidirectional transformations.
    ///
    /// - Parameters:
    ///   - original: The source editor containing the original value
    ///   - new: The destination editor that will contain the transformed value
    ///   - mapFrom: A closure that transforms from the source value type to the destination value type
    ///   - mapTo: A closure that transforms from the destination value type back to the source value type
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
