// FormCollectionViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 15:44 GMT.

import Foundation
import Observation

/// A view model for managing a collection of items in a form.
///
/// ``FormCollectionViewModel`` is a generic class that handles the data and interaction logic
/// for a form field that represents a collection of items. It conforms to the ``ObservableValueEditor``
/// protocol and provides functionality for adding, removing, moving, and selecting items
/// in the collection.
///
/// This class is particularly useful for forms that need to manage lists of related items,
/// such as a list of contacts, tasks, or any other repeating elements.
///
/// ## Features
/// - Manages a collection of identifiable items
/// - Supports adding, removing, and reordering items
/// - Provides item selection functionality
/// - Handles read-only state
/// - Allows for custom logic for item insertion, deletion, and movement
/// - Supports change tracking for the entire collection
///
/// ## Example with Basic Setup
///
/// ```swift
/// struct Contact: Identifiable {
///     let id: UUID
///     var name: String
///     var email: String
/// }
///
/// @QuickForm(PersonForm.self)
/// class PersonFormModel: Validatable {
///     @PropertyEditor(keyPath: \PersonForm.contacts)
///     var contacts = FormCollectionViewModel<Contact>(
///         type: Contact.self,
///         title: "Contacts:",
///         insertionTitle: "Add Contact"
///     )
///
///     init(model: PersonForm) {
///         super.init(model: model)
///         contacts.onInsert {
///             // Return a new Contact instance or present a UI for creation
///             return Contact(id: UUID(), name: "", email: "")
///         }
///     }
/// }
/// ```
///
/// ## Using with FormCollectionSection in SwiftUI
///
/// ```swift
/// struct ContactsView: View {
///     @Bindable var model: PersonFormModel
///
///     var body: some View {
///         Form {
///             FormCollectionSection(model.contacts) { contact in
///                 // How each item appears in the list
///                 VStack(alignment: .leading) {
///                     Text(contact.name)
///                         .font(.headline)
///                     Text(contact.email)
///                         .foregroundColor(.secondary)
///                 }
///             } onSelect: { contact in
///                 // Handle selection (e.g., navigate to edit view)
///                 await model.contacts.select(item: contact)
///             }
///         }
///     }
/// }
/// ```
///
/// ## Advanced Usage with Custom Editors
///
/// ```swift
/// // Configure editing behavior
/// init() {
///     tasks.onInsert {
///         // Create a new task
///         return Task(id: UUID(), title: "", completed: false)
///     }
///
///     tasks.onSelect { task in
///         // Present a task editor and return the updated task
///         return await TaskEditor.showSheet(for: task)
///     }
///
///     tasks.onChange { difference in
///         // Track changes to sync with backend
///         for change in difference {
///             switch change {
///             case .insert(_, let task, _):
///                 saveNewTask(task)
///             case .remove(_, let task, _):
///                 deleteTask(task)
///             }
///         }
///     }
///
///     tasks.onCanDelete { indexSet in
///         // Only allow deletion if task is not locked
///         return !indexSet.contains { tasks.value[$0].isLocked }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormCollectionSection``, ``ObservableValueEditor``, ``Subscription``
@Observable
public final class FormCollectionViewModel<Property: Identifiable & Sendable>: ObservableValueEditor {
    /// The title of the collection section.
    ///
    /// This property is typically displayed as a header for the collection
    /// in list-based or sectioned UIs.
    public var title: LocalizedStringResource

    /// The title for the insertion action (e.g., "Add Item").
    ///
    /// This text is typically used for buttons or menu items that trigger
    /// the insertion of new items into the collection.
    public var insertionTitle: LocalizedStringResource

    /// The current collection of items.
    ///
    /// When this value changes:
    /// - Any registered onChange handlers are called with the difference
    /// - All subscribers registered via `onValueChanged(_:)` are notified
    /// - Property change subscriptions are updated
    ///
    /// This property can be directly modified or changed through the `insert()`,
    /// `delete(at:)`, and `move(from:to:)` methods.
    public var value: [Property] {
        didSet {
            if let collectionChanged = _onChange {
                collectionChanged(value.difference(from: oldValue) { $0.id == $1.id })
            }
            dispatcher.publish(value)

            subscribeToPropertyChange()
        }
    }

    /// A boolean indicating whether the collection is read-only.
    ///
    /// When set to `true`, UI components should disable editing operations like
    /// adding, removing, or reordering items.
    public var isReadOnly: Bool

    /// A predicate that determines if a specific item can be selected.
    ///
    /// This closure is called by the `canSelect(item:)` method and allows
    /// for custom logic to determine item selectability.
    ///
    /// - Parameter item: The item to evaluate for selectability
    /// - Returns: `true` if the item can be selected, `false` otherwise
    public var onCanSelect: (Property) -> Bool = { _ in true }

    /// A predicate that determines if a new item can be inserted into the collection.
    ///
    /// This closure is called by the `canInsert()` method and allows
    /// for custom logic to control insertion permission.
    ///
    /// - Returns: `true` if insertion is allowed, `false` otherwise
    public var onCanInsert: () -> Bool = { true }

    /// A predicate that determines if items at specific offsets can be deleted.
    ///
    /// This closure is called by the `canDelete(at:)` method and allows
    /// for custom logic to control deletion permission.
    ///
    /// - Parameter atOffsets: The index set of items being considered for deletion
    /// - Returns: `true` if deletion is allowed, `false` otherwise
    public var onCanDelete: (_ atOffsets: IndexSet) -> Bool = { _ in true }

    /// A predicate that determines if items can be moved from source to destination.
    ///
    /// This closure is called by the `canMove(from:to:)` method and allows
    /// for custom logic to control movement permission.
    ///
    /// - Parameters:
    ///   - fromSource: The index set of items to move
    ///   - toDestination: The destination index
    /// - Returns: `true` if the move operation is allowed, `false` otherwise
    public var onCanMove: (_ fromSource: IndexSet, _ toDestination: Int) -> Bool = { _, _ in true }

    /// The closure called when inserting a new item.
    ///
    /// This optional async closure is responsible for creating and returning a new
    /// item when the `insert()` method is called.
    private var _onInsert: (() async -> Property?)?

    /// The closure called when the collection changes.
    ///
    /// This optional closure is called with a collection difference when
    /// the `value` property changes.
    private var _onChange: ((CollectionDifference<Property>) -> Void)?

    /// The closure called when an item is selected.
    ///
    /// This optional async closure is called with the selected item when
    /// the `select(item:)` method is called, and can return an updated version
    /// of the item.
    private var _onSelect: ((Property?) async -> Property?)?

    /// The dispatcher used to notify subscribers of value changes.
    private var dispatcher: Dispatcher

    /// Initializes a new instance of ``FormCollectionViewModel``.
    ///
    /// - Parameters:
    ///   - value: The initial collection of items.
    ///   - title: The title of the collection section.
    ///   - insertionTitle: The title for the insertion action.
    ///   - isReadOnly: A boolean indicating whether the collection is read-only.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let taskList = FormCollectionViewModel(
    ///     value: initialTasks,
    ///     title: "Tasks",
    ///     insertionTitle: "Add Task",
    ///     isReadOnly: false
    /// )
    /// ```
    public init(
        value: [Property],
        title: LocalizedStringResource = "",
        insertionTitle: LocalizedStringResource = "Add",
        isReadOnly: Bool = false
    ) {
        self.value = value
        self.title = title
        self.insertionTitle = insertionTitle
        self.isReadOnly = isReadOnly
        dispatcher = Dispatcher()

        subscribeToPropertyChange()
    }

    /// Checks if a new item can be inserted into the collection.
    ///
    /// This method delegates to the `onCanInsert` closure to determine
    /// if a new item can be added to the collection.
    ///
    /// - Returns: A boolean indicating whether insertion is allowed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a SwiftUI view
    /// Button("Add Contact") {
    ///     if model.contacts.canInsert() {
    ///         Task {
    ///             await model.contacts.insert()
    ///         }
    ///     }
    /// }
    /// .disabled(!model.contacts.canInsert())
    /// ```
    public func canInsert() -> Bool {
        onCanInsert()
    }

    /// Attempts to insert a new item into the collection.
    ///
    /// This method calls the async closure set by `onInsert(_:)` to create a new item.
    /// If an item is successfully created, it's appended to the collection.
    ///
    /// - Note: This method must be called from the main actor context.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a SwiftUI view
    /// .toolbar {
    ///     Button {
    ///         Task {
    ///             await model.contacts.insert()
    ///         }
    ///     } label: {
    ///         Label(model.contacts.insertionTitle, systemImage: "plus")
    ///     }
    /// }
    /// ```
    @MainActor
    public func insert() async {
        if canInsert(), let insertion = _onInsert {
            if let newValue = await insertion() {
                value.append(newValue)
            }
        }
    }

    /// Checks if the given item can be selected.
    ///
    /// This method delegates to the `onCanSelect` closure to determine
    /// if the specified item can be selected.
    ///
    /// - Parameter item: The item to check for selectability.
    /// - Returns: A boolean indicating whether the item can be selected.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let isSelectable = model.tasks.canSelect(item: task)
    ///
    /// // Configure UI based on selectability
    /// .foregroundColor(isSelectable ? .primary : .secondary)
    /// ```
    public func canSelect(item: Property) -> Bool {
        onCanSelect(item)
    }

    /// Selects the given item or deselects if nil is provided.
    ///
    /// This method calls the async closure set by `onSelect(_:)` with the selected item.
    /// If the closure returns an updated item, the item in the collection is updated.
    ///
    /// - Parameter item: The item to select, or nil to deselect.
    /// - Note: This method must be called from the main actor context.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a SwiftUI view's list
    /// ForEach(model.tasks.value) { task in
    ///     TaskRow(task: task)
    ///         .onTapGesture {
    ///             Task {
    ///                 await model.tasks.select(item: task)
    ///             }
    ///         }
    /// }
    /// ```
    @MainActor
    public func select(item: Property?) async {
        if let item {
            if canSelect(item: item) {
                if let updatedItem = await _onSelect?(item),
                   let index = value.firstIndex(where: { $0.id == item.id }) {
                    value[index] = updatedItem
                }
            }
        }
    }

    /// Checks if items at the given offsets can be deleted.
    ///
    /// This method delegates to the `onCanDelete` closure to determine
    /// if the items at the specified offsets can be deleted.
    ///
    /// - Parameter offsets: The offsets of items to check for deletion.
    /// - Returns: A boolean indicating whether the items can be deleted.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Check if specific items can be deleted
    /// let canRemoveItems = model.tasks.canDelete(at: IndexSet(0...2))
    ///
    /// // Use in SwiftUI List
    /// .onDelete { indexSet in
    ///     if model.tasks.canDelete(at: indexSet) {
    ///         model.tasks.delete(at: indexSet)
    ///     }
    /// }
    /// ```
    public func canDelete(at offsets: IndexSet) -> Bool {
        onCanDelete(offsets)
    }

    /// Deletes items at the given offsets from the collection.
    ///
    /// This method removes items at the specified offsets if deletion
    /// is allowed by the `canDelete(at:)` method.
    ///
    /// - Parameter offsets: The offsets of items to delete.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a SwiftUI view
    /// .onDelete { indexSet in
    ///     model.tasks.delete(at: indexSet)
    /// }
    /// ```
    public func delete(at offsets: IndexSet) {
        if canDelete(at: offsets) {
            value.remove(atOffsets: offsets)
        }
    }

    /// Checks if items can be moved from the source offsets to the destination index.
    ///
    /// This method delegates to the `onCanMove` closure to determine
    /// if the specified move operation is allowed.
    ///
    /// - Parameters:
    ///   - source: The current offsets of the items to move.
    ///   - destination: The destination offset to move the items to.
    /// - Returns: A boolean indicating whether the move operation is allowed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Check if a specific move is allowed
    /// let canReorder = model.priorities.canMove(
    ///     from: IndexSet([0]),
    ///     to: 3
    /// )
    /// ```
    public func canMove(from source: IndexSet, to destination: Int) -> Bool {
        onCanMove(source, destination)
    }

    /// Moves items from the source offsets to the destination index.
    ///
    /// This method moves items if the operation is allowed by the
    /// `canMove(from:to:)` method.
    ///
    /// - Parameters:
    ///   - source: The current offsets of the items to move.
    ///   - destination: The destination offset to move the items to.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a SwiftUI view
    /// .onMove { indexSet, index in
    ///     model.tasks.move(from: indexSet, to: index)
    /// }
    /// ```
    public func move(from source: IndexSet, to destination: Int) {
        if canMove(from: source, to: destination) {
            value.move(fromOffsets: source, toOffset: destination)
        }
    }

    /// Sets the closure to be called when attempting to insert a new item.
    ///
    /// - Parameter action: An async closure that returns an optional new item.
    /// - Returns: The `FormCollectionViewModel` instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// contacts.onInsert {
    ///     // Simple creation
    ///     return Contact(id: UUID(), name: "", email: "")
    /// }
    ///
    /// // Or with a UI prompt
    /// contacts.onInsert {
    ///     // Show a sheet or form to create a new contact
    ///     return await ContactCreationView.present()
    /// }
    /// ```
    @discardableResult
    public func onInsert(action: @escaping (() async -> Property?)) -> Self {
        _onInsert = action
        return self
    }

    /// Sets the closure to be called when the collection changes.
    ///
    /// - Parameter action: A closure that takes a `CollectionDifference<Property>` as its parameter.
    /// - Returns: The `FormCollectionViewModel` instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// contacts.onChange { difference in
    ///     // Track what changed
    ///     for change in difference {
    ///         switch change {
    ///         case .insert(_, let contact, _):
    ///             createContactOnServer(contact)
    ///         case .remove(_, let contact, _):
    ///             deleteContactFromServer(contact.id)
    ///         }
    ///     }
    /// }
    /// ```
    @discardableResult
    public func onChange(action: ((CollectionDifference<Property>) -> Void)?) -> Self {
        _onChange = action
        return self
    }

    /// Sets the closure to be called when an item is selected.
    ///
    /// - Parameter action: A closure that takes an optional `Property` and returns an optional updated `Property`.
    /// - Returns: The `FormCollectionViewModel` instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// contacts.onSelect { contact in
    ///     // Show an editor and return the updated contact
    ///     guard let contact else { return nil }
    ///     return await ContactEditorView.present(contact: contact)
    /// }
    /// ```
    @discardableResult
    public func onSelect(action: ((Property?) async -> Property?)?) -> Self {
        _onSelect = action
        return self
    }

    /// Sets a closure to be called when the collection value changes.
    ///
    /// - Parameter change: A closure that takes the new collection value as its parameter.
    /// - Returns: A ``Subscription`` that can be used to unsubscribe from value changes.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let subscription = model.tasks.onValueChanged { tasks in
    ///     // Update UI or perform actions when the tasks collection changes
    ///     updateTaskCountBadge(tasks.count)
    ///
    ///     // Check if all tasks are complete
    ///     let allComplete = tasks.allSatisfy(\.isComplete)
    ///     showCompletionBanner(allComplete)
    /// }
    ///
    /// // Later, when you no longer need the subscription:
    /// subscription.unsubscribe()
    /// ```
    ///
    /// - SeeAlso: ``Subscription``, ``Dispatcher``
    @discardableResult
    public func onValueChanged(_ change: @escaping ([Property]) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }

    /// Internal subscriptions to property changes.
    private var internalSubscription: [Subscription] = []

    /// Updates subscriptions to property changes.
    ///
    /// This method is called whenever the `value` property changes.
    /// It manages subscriptions to changes in individual properties
    /// if they conform to ``ObservableValueEditor``.
    private func subscribeToPropertyChange() {
        if let value = value as? [any ObservableValueEditor] {
            internalSubscription.forEach { $0.unsubscribe() }
            internalSubscription.removeAll()

            for property in value {
                let subscription = property.onValueChanged { [weak self] _ in
                    guard let self else { return }
                    dispatcher.publish(self.value)
                }

                internalSubscription.append(subscription)
            }
        }
    }
}

public extension FormCollectionViewModel {
    /// Convenience initializer that creates an empty collection.
    ///
    /// - Parameters:
    ///   - type: The type of collection items.
    ///   - title: The title of the collection section.
    ///   - insertionTitle: The title for the insertion action.
    ///   - isReadOnly: A boolean indicating whether the collection is read-only.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @PropertyEditor(keyPath: \TaskList.tasks)
    /// var tasks = FormCollectionViewModel(
    ///     type: Task.self,
    ///     title: "Tasks:",
    ///     insertionTitle: "Add Task"
    /// )
    ///
    /// // In a SwiftUI view
    /// FormCollectionSection(model.tasks) { task in
    ///     TaskRow(task: task)
    /// }
    /// .toolbar {
    ///     EditButton() // Enables built-in editing controls
    /// }
    /// ```
    convenience init(
        type: Property.Type,
        title: LocalizedStringResource = "",
        insertionTitle: LocalizedStringResource = "Add",
        isReadOnly: Bool = false
    ) {
        self.init(
            value: [],
            title: title,
            insertionTitle: insertionTitle,
            isReadOnly: isReadOnly
        )
    }
}
