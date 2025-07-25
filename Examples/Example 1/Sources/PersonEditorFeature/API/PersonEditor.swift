// PersonEditor.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

//
//  PersonEditor.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 8.9.24..
//
import SwiftUI
import UIKit

struct PersonEditorDelegate {
    var didTapOnDeactivate: (() -> Void)?
    var didTapOnAddTeamMember: ((_ completion: @escaping (PersonInfo?) -> Void) -> Void)?
}

enum PersonEditor {
    @MainActor
    static func personEditor(for person: Person, delegate: PersonEditorDelegate?) -> UIViewController {
        let viewModel = PersonEditModel(value: person)
        let view = PersonEditView(quickForm: viewModel, delegate: delegate)
        let wrappedView = Wrapped { view }
        let hostingController = UIHostingController(rootView: wrappedView)
        return hostingController
    }
}

struct Wrapped<Content: View>: View {
    let content: () -> Content
    var body: some View {
        NavigationStack {
            content()
        }
    }
}
