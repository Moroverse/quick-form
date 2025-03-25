// FormCollectionViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 15:44 GMT.

import Foundation
import Observation

/// A view model for managing a collection of items in a form.
///
/// `FormCollectionViewModel` is a generic class that handles the data and interaction logic
/// for a form field that represents a collection of items. It conforms to the `ValueEditor`
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
/// ## Example
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
///             // Hypothetical async view presentation
///         }
///     }
/// }
/// ```
@Observable
public final class FormCollectionViewModel<Property: Identifiable & Sendable>: ObservableValueEditor {
    /// The title of the collection section.
    public var title: LocalizedStringResource
    /// The title for the insertion action (e.g., "Add Item").
    public var insertionTitle: LocalizedStringResource
    /// The current collection of items.
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
    public var isReadOnly: Bool
    public var onCanSelect: (Property) -> Bool = { _ in true }
    public var onCanInsert: () -> Bool = { true }
    public var onCanDelete: (_ atOffsets: IndexSet) -> Bool = { _ in true }
    public var onCanMove: (_ fromSource: IndexSet, _ toDestination: Int) -> Bool = { _, _ in true }
    private var _onInsert: (() async -> Property?)?
    private var _onChange: ((CollectionDifference<Property>) -> Void)?
    private var _onSelect: ((Property?) async -> Property?)?
    private var dispatcher: Dispatcher
    /// Initializes a new instance of `FormCollectionViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial collection of items.
    ///   - title: The title of the collection section.
    ///   - insertionTitle: The title for the insertion action.
    ///   - isReadOnly: A boolean indicating whether the collection is read-only.
    public init(
        value: [Property],
        title: LocalizedStringResource = "",
        insertionTitle: LocalizedStringResource = "Add",
        isReadOnly: Bool = false
    ) {
        _value = value
        self.title = title
        self.insertionTitle = insertionTitle
        self.isReadOnly = isReadOnly
        dispatcher = Dispatcher()
    }

    /// Checks if a new item can be inserted into the collection.
    ///
    /// - Returns: A boolean indicating whether insertion is allowed.
    public func canInsert() -> Bool {
        onCanInsert()
    }

    /// Attempts to insert a new item into the collection.
    ///
    /// This method calls the async closure set by `onInsert(_:)` to create a new item.
    /// If an item is successfully created, it's appended to the collection.
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
    /// - Parameter item: The item to check for selectability.
    /// - Returns: A boolean indicating whether the item can be selected.
    public func canSelect(item: Property) -> Bool {
        onCanSelect(item)
    }

    /// Selects the given item or deselects if nil is provided.
    ///
    /// - Parameter item: The item to select, or nil to deselect.
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
    /// - Parameter offsets: The offsets of items to check for deletion.
    /// - Returns: A boolean indicating whether the items can be deleted.
    public func canDelete(at offsets: IndexSet) -> Bool {
        onCanDelete(offsets)
    }

    /// Deletes items at the given offsets from the collection.
    ///
    /// - Parameter offsets: The offsets of items to delete.
    public func delete(at offsets: IndexSet) {
        if canDelete(at: offsets) {
            value.remove(atOffsets: offsets)
        }
    }

    /// Checks if items can be moved from the source offsets to the destination index.
    ///
    /// - Parameters:
    ///   - source: The current offsets of the items to move.
    ///   - destination: The destination offset to move the items to.
    /// - Returns: A boolean indicating whether the move operation is allowed.
    public func canMove(from source: IndexSet, to destination: Int) -> Bool {
        onCanMove(source, destination)
    }

    /// Moves items from the source offsets to the destination index.
    ///
    /// - Parameters:
    ///   - source: The current offsets of the items to move.
    ///   - destination: The destination offset to move the items to.
    public func move(from source: IndexSet, to destination: Int) {
        if canMove(from: source, to: destination) {
            value.move(fromOffsets: source, toOffset: destination)
        }
    }

    /// Sets the closure to be called when attempting to insert a new item.
    ///
    /// - Parameter action: An async closure that returns an optional new item.
    /// - Returns: The `FormCollectionViewModel` instance for method chaining.
    @discardableResult
    public func onInsert(action: @escaping (() async -> Property?)) -> Self {
        _onInsert = action
        return self
    }

    /// Sets the closure to be called when the collection changes.
    ///
    /// - Parameter action: A closure that takes a `CollectionDifference<Property>` as its parameter.
    /// - Returns: The `FormCollectionViewModel` instance for method chaining.
    @discardableResult
    public func onChange(action: ((CollectionDifference<Property>) -> Void)?) -> Self {
        _onChange = action
        return self
    }

    /// Sets the closure to be called when an item is selected or deselected.
    ///
    /// - Parameter action: A closure that takes an optional `Property` as its parameter.
    /// - Returns: The `FormCollectionViewModel` instance for method chaining.
    @discardableResult
    public func onSelect(action: ((Property?) async -> Property?)?) -> Self {
        _onSelect = action
        return self
    }

    public func onValueChanged(_ change: @escaping ([Property]) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }

    private var internalSubscription: [Subscription] = []
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
    /// Convenience initializer that uses a collection with a default value item.
    ///
    /// - Parameters:
    ///   - type: The type of collection items.
    ///   - title: The title of the collection section.
    ///   - insertionTitle: The title for the insertion action.
    ///   - isReadOnly: A boolean indicating whether the collection is read-only.
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
