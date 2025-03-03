// ValueEditorTransformer.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 15:46 GMT.

import Observation

/// A transformer that creates a bidirectional connection between a source value editor
/// and a transformed representation.
///
/// `ValueEditorTransformer` enables you to work with different representations of the same
/// underlying data while maintaining bidirectional synchronization. When the source editor
/// changes, the transformer's value is updated automatically. Similarly, when the
/// transformer's value changes, the source editor is updated.
///
/// Unlike `ModelTransformer`, this class is Observable and provides change notification
/// through the Observation framework.
@Observable
public final class ValueEditorTransformer<SourceEditor, Transformed>: ObservableValueEditor
    where SourceEditor: ObservableValueEditor {
    @ObservationIgnored
    private var settingValue = false
    /// The transformed value.
    ///
    /// When this value is set, the source editor's value is updated using `transformToSource`.
    /// Changes to this property trigger observation updates in SwiftUI views.
    public var value: Transformed {
        didSet {
            if settingValue == true { return }
            settingValue = true
            sourceEditor.value = transformToSource(value)
            settingValue = false
            dispatcher.publish(value)
        }
    }

    /// Registers a callback to be invoked when the transformed value changes.
    ///
    /// - Parameter change: A closure that will be called whenever the value changes,
    ///   with the new value as its parameter.
    /// - Returns: The transformer instance for method chaining.
    @discardableResult
    public func onValueChanged(_ change: @escaping (Transformed) -> Void) -> Self {
        dispatcher.subscribe(handler: change)
        return self
    }

    /// The source editor that provides the original value.
    @ObservationIgnored
    public private(set) var sourceEditor: SourceEditor

    private let transformFromSource: (SourceEditor.Value) -> Transformed
    private let transformToSource: (Transformed) -> SourceEditor.Value
    private let dispatcher: Dispatcher

    /// Creates a new value editor transformer that connects a source editor with a transformed representation.
    ///
    /// - Parameters:
    ///   - original: The source editor containing the original value
    ///   - transformFromSource: A closure that transforms from the source value type to the destination value type
    ///   - transformToSource: A closure that transforms from the destination value type back to the source value type
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

        sourceEditor.onValueChanged { [weak self] in
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
    /// This method provides a convenient way to create a `ValueEditorTransformer` from
    /// any value editor, allowing you to work with a transformed representation of the
    /// original value while maintaining bidirectional synchronization.
    ///
    /// - Parameters:
    ///   - transformFromSource: A closure that transforms from the source value type to the transformed value type
    ///   - transformToSource: A closure that transforms from the transformed value type back to the source value type
    /// - Returns: A new `ValueEditorTransformer` that provides the transformed representation
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
