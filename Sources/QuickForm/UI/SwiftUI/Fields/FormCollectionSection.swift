// FormCollectionSection.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 13:42 GMT.

import SwiftUI

/// A SwiftUI view that represents a section for managing a collection of items in a form.
///
/// `FormCollectionSection` is designed to work with ``FormCollectionViewModel`` to provide
/// a dynamic, editable list of items within a form. This view is particularly useful for managing
/// lists of related items, such as contacts, tasks, or any other repeating elements in a form.
///
/// ## Features
/// - Displays a list of items with custom content for each item
/// - Supports adding new items to the collection
/// - Allows for item deletion and reordering
/// - Provides item selection functionality
/// - Supports customization through a configuration closure
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```swift
/// struct Contact: Identifiable {
///     let id = UUID()
///     var name: String
///     var phone: String
/// }
///
/// struct ContactsForm: View {
///     @Bindable var viewModel = FormCollectionViewModel(
///         value: [
///             Contact(name: "Alice", phone: "555-1234"),
///             Contact(name: "Bob", phone: "555-5678")
///         ],
///         title: "Contacts",
///         insertionTitle: "Add Contact"
///     )
///
///     var body: some View {
///         Form {
///             FormCollectionSection(viewModel) { $contact in
///                 VStack(alignment: .leading) {
///                     Text(contact.name).font(.headline)
///                     Text(contact.phone).font(.caption)
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// ### With Custom Insertion Logic
///
/// ```swift
/// FormCollectionSection(viewModel) { $task in
///     HStack {
///         Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
///             .onTapGesture {
///                 task.isCompleted.toggle()
///             }
///         Text(task.title)
///     }
/// }
/// .configure { vm in
///     vm.onInsert {
///         // Show a dialog to create a new task
///         let newTask = await TaskCreationView.presentAsSheet()
///         if let task = newTask {
///             vm.value.append(task)
///         }
///         return true // indicate successful insertion
///     }
/// }
/// ```
///
/// ### With Selection Handling
///
/// ```swift
/// FormCollectionSection(contactsViewModel) { $contact in
///     Text(contact.name)
/// }
/// .configure { vm in
///     vm.onSelect { contact in
///         if let contact = contact {
///             // Navigate to contact detail view
///             navigationPath.append(contact)
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormCollectionViewModel``, ``FormField``
public struct FormCollectionSection<Property: Identifiable & Sendable, Content: View>: View {
    @Bindable private var viewModel: FormCollectionViewModel<Property>
    private let content: (Binding<Property>) -> Content

    /// The body of the `FormCollectionSection` view.
    ///
    /// This view consists of:
    /// - A section header displaying the title from the view model
    /// - A dynamic list of items from the view model's `value` array
    /// - Each item is rendered using the provided `content` closure
    /// - Support for deleting and reordering items (when enabled)
    /// - An optional "add" button when insertion is enabled
    public var body: some View {
        Section {
            ForEach($viewModel.value) { $item in
                content($item)
                    .frame(maxWidth: .infinity)
                    .animation(.default)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await viewModel.select(item: item)
                        }
                    }
            }
            .onMove { from, to in
                viewModel.move(from: from, to: to)
            }
            .onDelete { offsets in
                viewModel.delete(at: offsets)
            }

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
    ///   - viewModel: The ``FormCollectionViewModel`` that manages the state of this collection section.
    ///   - content: A closure that returns the view to display for each item in the collection.
    ///     The closure receives a binding to each item, allowing direct modification of the item's properties.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormCollectionSection(taskListViewModel) { $task in
    ///     HStack {
    ///         Toggle("", isOn: $task.isCompleted)
    ///         TextField("Task name", text: $task.name)
    ///     }
    /// }
    /// ```
    public init(
        _ viewModel: FormCollectionViewModel<Property>,
        content: @escaping @autoclosure () -> (Binding<Property>) -> Content
    ) {
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
    /// - Parameter configuration: A closure that takes a ``FormCollectionViewModel`` instance
    ///   and performs configuration.
    /// - Returns: The modified `FormCollectionSection` instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormCollectionSection(notesViewModel) { $note in
    ///     Text(note.title)
    /// }
    /// .configure { vm in
    ///     // Set up insertion logic
    ///     vm.onInsert {
    ///         let newNote = Note(title: "New Note", content: "")
    ///         vm.value.append(newNote)
    ///         return true
    ///     }
    ///
    ///     // Set up selection handling
    ///     vm.onSelect { note in
    ///         if let note = note {
    ///             selectedNote = note
    ///             showNoteEditor = true
    ///         }
    ///     }
    /// }
    /// ```
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
        FormCollectionSection(form) { $person in
            Text(person.name)
        }
    }
}
