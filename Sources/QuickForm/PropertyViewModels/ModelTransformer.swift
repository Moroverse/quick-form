//
//  ModelTransformer.swift
//  quick-form
//
//  Created by Daniel Moro on 18.9.24..
//
import Observation

public final class ModelTransformer<SourceEditor, DestinationEditor>: ValueEditor where SourceEditor: ValueEditor, DestinationEditor: ValueEditor {
    public var value: DestinationEditor.Value {
        get {
            new.value = mapFrom(original.value)
            return new.value
        }
        set {
            original.value = mapTo(new.value)
        }
    }

    public private (set) var original: SourceEditor
    public private (set) var new: DestinationEditor

    private let mapFrom: (SourceEditor.Value) -> DestinationEditor.Value
    private let mapTo: (DestinationEditor.Value) -> SourceEditor.Value

    public init(original: SourceEditor, new: DestinationEditor, mapFrom: @escaping (SourceEditor.Value) -> DestinationEditor.Value, mapTo: @escaping (DestinationEditor.Value) -> SourceEditor.Value) {
        self.original = original
        self.new = new
        self.mapTo = mapTo
        self.mapFrom = mapFrom
    }
}
