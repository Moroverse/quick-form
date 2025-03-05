//
//  FormTextEditorTests.swift
//  quick-form
//
//  Created by Daniel Moro on 5.3.25..
//

import XCTest
@testable import QuickForm
import ViewInspector

@MainActor
final class FormTextFieldTests: XCTestCase {

    func testTitle() {
        let viewModel = FormFieldViewModel(
            value: "value",
            title: "title",
            placeholder: "placeholder",
            isReadOnly: false,
            validation: nil
        )
        let sut = FormTextField(viewModel)
        let exp = sut.inspection.inspect { view in
            XCTAssertNotNil(try view.find(viewWithAccessibilityIdentifier: "TITLE").text())
//            XCTAssertEqual(try view.find(viewWithAccessibilityIdentifier: "TITLE").text().string(), "title")
        }

        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.1)
    }
}
