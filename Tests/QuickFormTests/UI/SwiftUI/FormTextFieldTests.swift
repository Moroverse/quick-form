// FormTextFieldTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 09:26 GMT.

@testable import QuickForm
import SwiftUI
import ViewInspector
import XCTest

@MainActor
final class FormTextFieldTests: XCTestCase {
    func testTitle() {
        let viewModel = FormFieldViewModel(
            value: "",
            title: "title"
        )
        let sut = FormTextField(viewModel)

        inspect(view: sut) { inspectableView in
            XCTAssertNotNil(try inspectableView.find(viewWithAccessibilityIdentifier: "TITLE").text())
        }
    }

    func testValue() {
        let viewModel = FormFieldViewModel(
            value: "value"
        )
        let sut = FormTextField(viewModel)

        inspect(view: sut) { inspectableView in
            XCTAssertEqual(try inspectableView.find(viewWithAccessibilityIdentifier: "VALUE").textField().input(), "value")
        }
    }

    func testPlaceholder() {
        let viewModel = FormFieldViewModel(
            value: "value",
            placeholder: "placeholder"
        )
        let sut = FormTextField(viewModel)

        inspect(view: sut) { inspectableView in
            XCTAssertEqual(try inspectableView.find(viewWithAccessibilityIdentifier: "VALUE").textField().labelView().text().string(), "placeholder")
        }
    }

    private func inspect<V: View & InspectableForm>(view: V, inspection: @escaping @MainActor @Sendable (InspectableView<ViewType.View<V>>) async throws -> Void) {
        let exp = view.inspection.inspect(inspection)
        ViewHosting.host(view: view)
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.1)
    }
}
