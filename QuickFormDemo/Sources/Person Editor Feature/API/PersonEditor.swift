//
//  PersonEditor.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 8.9.24..
//
import UIKit
import SwiftUI

struct PersonEditorDelegate {
    var didTapOnDeactivate: (() -> Void)?
    var didTapOnAddTeamMember: ((_ completion: @escaping (PersonInfo?) -> Void) -> Void)?
}

enum PersonEditor {
    @MainActor
    static func personEditor(for person: Person, delegate: PersonEditorDelegate?) -> UIViewController {
        let viewModel = PersonEditModel(model: person)
        let view = PersonEditView(quickForm: viewModel, delegate: delegate)
        return UIHostingController(rootView: view)
    }
}
