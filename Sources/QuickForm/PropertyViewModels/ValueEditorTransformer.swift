// ValueEditorTransformer.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-29 15:46 GMT.

public final class ValueEditorTransformer<SourceEditor, Transformed>: ValueEditor
    where SourceEditor: ObservableValueEditor {
    private var settingValue = false
    public var value: Transformed {
        didSet {
            settingValue = true
            sourceEditor.value = transformToSource(value)
            settingValue = false
        }
    }

    public private(set) var sourceEditor: SourceEditor

    private let transformFromSource: (SourceEditor.Value) -> Transformed
    private let transformToSource: (Transformed) -> SourceEditor.Value

    public init(
        original: SourceEditor,
        transformFromSource: @escaping (SourceEditor.Value) -> Transformed,
        transformToSource: @escaping (Transformed) -> SourceEditor.Value
    ) {
        sourceEditor = original
        self.transformToSource = transformToSource
        self.transformFromSource = transformFromSource
        value = transformFromSource(original.value)

        sourceEditor.onValueChanged { [weak self] in
            if self?.settingValue == true { return }
            self?.value = transformFromSource($0)
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
