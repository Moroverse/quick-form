// ModelTransformer.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-18 04:54 GMT.

import Observation

public final class ModelTransformer<SourceEditor, DestinationEditor>: ValueEditor
    where SourceEditor: ValueEditor, DestinationEditor: ValueEditor {
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

    public private(set) var original: SourceEditor
    public private(set) var new: DestinationEditor

    private let mapFrom: (SourceEditor.Value) -> DestinationEditor.Value
    private let mapTo: (DestinationEditor.Value) -> SourceEditor.Value

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
