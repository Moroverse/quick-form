// ValueEditorTransformer.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 15:46 GMT.

import Observation

@Observable
public final class ValueEditorTransformer<SourceEditor, Transformed>: ObservableValueEditor
where SourceEditor: ObservableValueEditor {
    @ObservationIgnored
    private var settingValue = false
    public var value: Transformed {
        didSet {
            if settingValue == true { return }
            settingValue = true
            sourceEditor.value = transformToSource(value)
            settingValue = false
            dispatcher.publish(value)
        }
    }

    @discardableResult
    public func onValueChanged(_ change: @escaping (Transformed) -> Void) -> Self {
        dispatcher.subscribe(handler: change)
        return self
    }

    @ObservationIgnored
    public private(set) var sourceEditor: SourceEditor

    private let transformFromSource: (SourceEditor.Value) -> Transformed
    private let transformToSource: (Transformed) -> SourceEditor.Value
    private let dispatcher: Dispatcher

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
