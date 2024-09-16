// FormCollectionSection.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 13:42 GMT.

import SwiftUI

/// A SwiftUI view that represents a section for managing a collection of items in a form.
///
/// `FormCollectionSection` is designed to work with `FormCollectionViewModel<Property>` to provide
/// a dynamic, editable list of items within a form. This view is particularly useful for managing
/// lists of related items, such as contacts, tasks, or any other repeating elements in a form.
///
/// ## Features
/// - Displays a list of items with custom content for each item
/// - Supports adding new items to the collection
/// - Allows for item deletion and reordering (when enabled)
/// - Provides item selection functionality
/// - Supports customization through a configuration closure
///
/// ## Example
///
/// ```swift
/// struct Contact: Identifiable {
///     let id = UUID()
///     var name: String
/// }
///
/// struct ContactsForm: View {
///     @State private var viewModel = FormCollectionViewModel(
///         value: [Contact(name: "Alice"), Contact(name: "Bob")],
///         title: "Contacts",
///         insertionTitle: "Add Contact"
///     )
///
///     var body: some View {
///         Form {
///             FormCollectionSection(viewModel) { contact in
///                 Text(contact.name)
///             }
///             .configure { vm in
///                 vm.onInsert {
///                     await AddContactView.present() // Hypothetical async view presentation
///                 }
///             }
///         }
///     }
/// }
/// ```
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

    /// Initializes a new `FormCollectionSection`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state of this collection section.
    ///   - content: A closure that returns the view to display for each item in the collection.
    public init(_ viewModel: FormCollectionViewModel<Property>, content: @escaping @autoclosure () -> (Property) -> Content) {
        self.viewModel = viewModel
        self.content = content()
    }
}

public extension FormCollectionSection {
    /// Applies a configuration closure to the view model.
    ///
    /// Use this method to customize the behavior of the collection view model, such as
    /// setting up insertion, selection, or change handling logic.
    ///
    /// - Parameter configuration: A closure that takes a `FormCollectionViewModel<Property>` and performs configuration.
    /// - Returns: The modified `FormCollectionSection` instance.
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
