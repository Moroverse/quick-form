// Inspection.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 07:19 GMT.

import Combine
import SwiftUI

final class Inspection<V> {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

struct InspectionModifier<V: View>: ViewModifier {
    let inspection: Inspection<V>
    let view: V
    func body(content: Content) -> some View {
        content
            .onReceive(inspection.notice) { inspection.visit(view, $0) }
    }

    init(inspection: Inspection<V>, in view: V) {
        self.inspection = inspection
        self.view = view
    }
}

#if DEBUG
    protocol InspectableForm {
        var inspection: Inspection<Self> { get }
    }
#endif

extension View {
    func registerForInspection<V: View>(_ inspection: Inspection<V>, in view: V) -> some View {
        #if DEBUG
            modifier(InspectionModifier(inspection: inspection, in: view))
        #else
            self
        #endif
    }
}
