// FormCollectionSection.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 13:42 GMT.

import SwiftUI

public struct FormCollectionSection<Property: Identifiable, Content: View>: View {
    @Bindable private var viewModel: FormCollectionViewModel<Property>
    // private let content: Content
    private let content: (Property) -> Content

    public var body: some View {
        Section {
//            if #available(iOS 18.0, *) {
//                ForEach(subviews: content) { subview in
//                    subview
//                }
//            } else {
            ForEach(viewModel.value) { item in
                content(item)
                    .onTapGesture {
                        if viewModel.canSelect(item: item) {
                            viewModel.select(item: item)
                        }
                    }
            }

            .onMove { from, to in
                if viewModel.canMove(from: from, to: to) {
                    viewModel.move(from: from, to: to)
                }
            }
            .onDelete { offsets in
                if viewModel.canDelete(at: offsets) {
                    viewModel.delete(at: offsets)
                }
            }
//            }
            if viewModel.canInsert() {
                Button {
                    Task {
                        await viewModel.insert()
                    }
                } label: {
                    Label(String(localized: viewModel.insertionTitle), systemImage: "plus.circle.fill")
                }
            }
        } header: {
            Text(viewModel.title)
        }
    }

    public init(_ viewModel: FormCollectionViewModel<Property>, content: @escaping @autoclosure () -> (Property) -> Content) {
        self.viewModel = viewModel
        self.content = content()
    }
}

public extension FormCollectionSection {
    func configure(_ configuration: @escaping (FormCollectionViewModel<Property>) -> Void) -> Self {
        configuration(viewModel)
        return self
    }
}

struct SimplePerson: Identifiable {
    let id = UUID()
    let name: String
}

#Preview {
    @Previewable @State var form = FormCollectionViewModel(
        value: [SimplePerson(name: "Pera"), SimplePerson(name: "Mika")],
        title: "People"
    )

    Form {
        FormCollectionSection(form) { person in
            Text(person.name)
        }
    }
}
