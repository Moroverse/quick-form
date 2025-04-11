// ValueEditorTransformerTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-04 06:47 GMT.

import QuickForm
import Testing

/// A simple implementation of ObservableValueEditor for testing purposes
struct FakeSubscription: Subscription {
    func unsubscribe() {}
}

class TestObservableEditor<T>: ObservableValueEditor {
    typealias Value = T
    private var callbacks: [(T) -> Void] = []

    var value: T {
        didSet {
            notifyCallbacks()
        }
    }

    init(value: T) {
        self.value = value
    }

    @discardableResult
    func onValueChanged(_ change: @escaping (T) -> Void) -> any Subscription {
        callbacks.append(change)
        return FakeSubscription()
    }

    private func notifyCallbacks() {
        callbacks.forEach { $0(value) }
    }
}

@Suite("ValueEditorTransformer Tests")
struct ValueEditorTransformerTests {
    @Test("Initializes with correct transformed value")
    func initialization() {
        let sourceEditor = TestObservableEditor<String>(value: "42")
        let transformer = ValueEditorTransformer(
            original: sourceEditor,
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        #expect(transformer.value == 42)
    }

    @Test("Updates source editor when transformed value changes")
    func updateSourceOnValueChange() {
        let sourceEditor = TestObservableEditor<String>(value: "10")
        let transformer = ValueEditorTransformer(
            original: sourceEditor,
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        #expect(sourceEditor.value == "10")
        #expect(transformer.value == 10)

        transformer.value = 50
        #expect(sourceEditor.value == "50")
        #expect(transformer.value == 50)
    }

    @Test("Updates transformer when source editor changes")
    func updateTransformerOnSourceChange() {
        let sourceEditor = TestObservableEditor<String>(value: "100")
        let transformer = ValueEditorTransformer(
            original: sourceEditor,
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        #expect(sourceEditor.value == "100")
        #expect(transformer.value == 100)

        sourceEditor.value = "250"
        #expect(transformer.value == 250)
    }

    @Test("Notifies callbacks when transformed value changes directly")
    func notifyCallbacksOnDirectChange() {
        let sourceEditor = TestObservableEditor<String>(value: "42")
        let transformer = ValueEditorTransformer(
            original: sourceEditor,
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        var callbackValue: Int?
        var callbackCount = 0

        transformer.onValueChanged { value in
            callbackValue = value
            callbackCount += 1
        }

        transformer.value = 100
        #expect(callbackCount == 1)
        #expect(callbackValue == 100)
    }

    @Test("Notifies callbacks when transformed value changes via source")
    func notifyCallbacksOnIndirectChange() {
        let sourceEditor = TestObservableEditor<String>(value: "42")
        let transformer = ValueEditorTransformer(
            original: sourceEditor,
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        var callbackValue: Int?
        var callbackCount = 0

        transformer.onValueChanged { value in
            callbackValue = value
            callbackCount += 1
        }

        sourceEditor.value = "200"
        #expect(callbackCount == 1)
        #expect(callbackValue == 200)
    }

    @Test("Prevents infinite recursion during updates")
    func preventInfiniteRecursion() {
        let sourceEditor = TestObservableEditor<String>(value: "42")
        let transformer = ValueEditorTransformer(
            original: sourceEditor,
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        var sourceCallbacks = 0
        var transformerCallbacks = 0

        sourceEditor.onValueChanged { _ in
            sourceCallbacks += 1
        }

        transformer.onValueChanged { _ in
            transformerCallbacks += 1
        }

        // This should trigger only one update in each direction, not an infinite loop
        transformer.value = 100

        #expect(sourceCallbacks == 1)
        #expect(transformerCallbacks == 1)
    }

    @Test("Extension method `map` creates same transformer as direct init")
    func extensionMethod() {
        let sourceEditor = TestObservableEditor<String>(value: "42")

        let transformer1 = ValueEditorTransformer(
            original: sourceEditor,
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        let transformer2 = sourceEditor.map(
            transformFromSource: { Int($0) ?? 0 },
            transformToSource: { String($0) }
        )

        #expect(transformer1.value == transformer2.value)

        transformer1.value = 100
        transformer2.value = 100
        #expect(transformer1.value == transformer2.value)
        #expect(sourceEditor.value == "100")
    }
}
