// TokenSetViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation
import Observation

/// A view model for managing a collection of identifiable items displayed as tokens in a form field.
///
/// `TokenSetViewModel` provides a way to manage a dynamic collection of tokens (such as tags, labels, or categories)
/// that users can add, remove, and select. It supports custom validation for token insertion and deletion,
/// and provides notification mechanisms for value changes.
///
/// This view model is designed to work with ``FormTokenSetField`` to create interactive token input fields
/// in SwiftUI forms.
///
/// > Note: When used with ``FormTokenSetField``, token insertion, removal, and selection are automatically handled
/// > by the UI component. There is no need to manually call `insert(_:)`, `remove(id:)`, or manage the `selection`
/// > property unless you're implementing custom UI behaviors.
///
/// ## Features
/// - Manages a collection of identifiable items
/// - Supports adding new tokens via text input
/// - Validates token insertion and deletion
/// - Tracks token selection
/// - Notifies subscribers of collection changes
///
/// ## Examples
///
/// ### Basic Tag Input Field
///
/// ```swift
/// // Define a simple tag structure
/// struct Tag: Identifiable, CustomStringConvertible {
///     var id = UUID()
///     let name: String
///
///     var description: String { name }
/// }
///
/// // Create a token set view model for tags
/// let tagViewModel = TokenSetViewModel<Tag>(
///     value: [Tag(name: "Swift"), Tag(name: "SwiftUI")],
///     title: "Tags",
///     insertionPlaceholder: "Add a tag...",
///     insertionMapper: { input in
///         // Create a new tag from user input
///         input.isEmpty ? nil : Tag(name: input)
///     }
/// )
///
/// // Create a form field using the view model
/// FormTokenSetField(tagViewModel)
/// // The FormTokenSetField automatically handles adding/removing tokens
/// ```
///
/// ### Skills Management (Real Example)
///
/// ```swift
/// @QuickForm(Experience.self)
/// class ExperienceViewModel: Validatable {
///     @PropertyEditor(keyPath: \Experience.skills)
///     var skills = TokenSetViewModel(
///         value: [ExperienceSkill](),
///         title: "Skills",
///         insertionPlaceholder: "Enter a new skill"
///     ) { newString in
///         ExperienceSkill(id: UUID(), name: newString, level: 1)
///     }
/// }
///
/// // In your view
/// FormTokenSetField(model.skills)
/// ```
///
/// - SeeAlso: ``FormTokenSetField``, ``ObservableValueEditor``, ``Dispatcher``
@Observable
public final class TokenSetViewModel<Property: Identifiable & CustomStringConvertible>: ObservableValueEditor {
    private var insertionMapper: ((String) -> Property?)?
    private var _onSelect: ((Property?) -> Void)?

    /// Determines whether new tokens can be inserted.
    ///
    /// Returns `true` if an insertion placeholder is provided, otherwise `false`.
    ///
    /// > Note: When using with ``FormTokenSetField``, this property is automatically respected
    /// > by the UI component, which will show or hide the insertion field accordingly.
    var canInsert: Bool { insertionPlaceholder != nil }

    /// The title of the token field.
    ///
    /// This title is typically displayed as a label for the token field in the UI.
    public var title: LocalizedStringResource?

    /// A placeholder text displayed in the insertion field.
    ///
    /// This text provides guidance to users about what kind of tokens they can add.
    /// If this property is `nil`, the token field will not allow inserting new tokens.
    public var insertionPlaceholder: LocalizedStringResource?

    /// A closure that determines if a token can be deleted.
    ///
    /// You can provide a custom implementation to prevent certain tokens from being deleted.
    /// By default, all tokens can be deleted.
    ///
    /// When used with ``FormTokenSetField``, this closure is automatically called before
    /// removing a token, providing delete validation without additional code.
    ///
    /// ## Example
    ///
    /// ```swift
    /// tokenViewModel.onCanDelete = { token in
    ///     // Prevent deletion of system-generated tags
    ///     return !token.isSystemGenerated
    /// }
    /// ```
    public var onCanDelete: (_ value: Property) -> Bool = { _ in true }

    /// The ID of the currently selected token.
    ///
    /// When this property changes, the `onSelect` closure is called with the corresponding token.
    /// This allows you to respond to token selection events in your UI.
    ///
    /// > Note: When using ``FormTokenSetField``, token selection is automatically managed by the UI component.
    public var selection: Property.ID? {
        didSet {
            if let _onSelect, let value = value.first(where: { $0.id == self.selection }) {
                _onSelect(value)
            }
        }
    }

    /// The collection of tokens managed by this view model.
    ///
    /// When this property changes:
    /// - All subscribers registered via `onValueChanged(_:)` are notified
    /// - The UI is updated to reflect the new collection
    public var value: [Property] {
        didSet {
            if let oldH = oldValue as? AnyHashable,
               let newH = value as? AnyHashable,
               oldH == newH {
                return
            }
            dispatcher.publish(value)
        }
    }

    /// The dispatcher used to notify subscribers of value changes.
    private var dispatcher: Dispatcher

    /// Initializes a new instance of `TokenSetViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial collection of tokens.
    ///   - title: An optional title for the token field.
    ///   - insertionPlaceholder: An optional placeholder text for the insertion field.
    ///     If this is `nil`, users won't be able to add new tokens.
    ///   - insertionMapper: An optional closure that maps text input to new tokens.
    ///     This closure should return a new token instance or `nil` if the input is invalid.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let skillsViewModel = TokenSetViewModel<Skill>(
    ///     value: user.skills,
    ///     title: "Skills",
    ///     insertionPlaceholder: "Add a skill...",
    ///     insertionMapper: { skillName in
    ///         // Only allow non-empty skill names
    ///         skillName.isEmpty ? nil : Skill(name: skillName)
    ///     }
    /// )
    /// ```
    public init(value: [Property], title: LocalizedStringResource? = nil, insertionPlaceholder: LocalizedStringResource?, insertionMapper: ((String) -> Property?)? = nil) {
        self.title = title
        self.value = value
        self.insertionPlaceholder = insertionPlaceholder
        self.insertionMapper = insertionMapper
        dispatcher = Dispatcher()
    }

    /// Attempts to insert a new token from the given text input.
    ///
    /// This method uses the `insertionMapper` provided during initialization
    /// to convert the input text into a token object. If the mapper returns
    /// a non-nil value, it's added to the collection.
    ///
    /// > Note: When using ``FormTokenSetField``, token insertion is automatically handled
    /// > by the UI component. You typically don't need to call this method directly.
    ///
    /// - Parameter input: The text input to convert into a token.
    /// - Returns: `true` if a token was successfully created and added, `false` otherwise.
    public func insert(_ input: String) -> Bool {
        guard let mapper = insertionMapper else { return false }
        if let newValue = mapper(input) {
            value.append(newValue)
            return true
        } else {
            return false
        }
    }

    /// Removes a token with the specified ID.
    ///
    /// > Note: When using ``FormTokenSetField``, token removal is automatically handled
    /// > by the UI component. You typically don't need to call this method directly.
    ///
    /// - Parameter id: The ID of the token to remove.
    public func remove(id: Property.ID?) {
        value.removeAll(where: { $0.id == id })
    }

    /// Sets a closure to be called when a token is selected.
    ///
    /// This method allows you to respond to token selection events
    /// by providing a handler that receives the selected token.
    ///
    /// - Parameter action: A closure that takes the selected token as its parameter.
    /// - Returns: The view model instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// tokenViewModel.onSelect { selectedToken in
    ///     if let token = selectedToken {
    ///         showDetailView(for: token)
    ///     }
    /// }
    /// ```
    @discardableResult
    public func onSelect(action: ((Property?) -> Void)?) -> Self {
        _onSelect = action
        return self
    }

    /// Determines if a specific token can be deleted.
    ///
    /// This method uses the `onCanDelete` closure to determine
    /// if a token can be removed from the collection.
    ///
    /// > Note: When using ``FormTokenSetField``, this validation is automatically applied
    /// > by the UI component when users attempt to remove tokens.
    ///
    /// - Parameter value: The token to check.
    /// - Returns: `true` if the token can be deleted, `false` otherwise.
    public func canDelete(_ value: Property) -> Bool {
        onCanDelete(value)
    }

    /// Sets a closure to be called when the collection of tokens changes.
    ///
    /// This method registers a callback that will be invoked whenever the token
    /// collection is modified (tokens added or removed).
    ///
    /// - Parameter change: A closure that takes the new collection as its parameter.
    /// - Returns: A ``Subscription`` object that can be used to unsubscribe when needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let subscription = tokenViewModel.onValueChanged { tokens in
    ///     // Update dependent state or perform side effects
    ///     updateCharacterCount(tokens.count)
    ///     saveTokensToDatabase(tokens)
    /// }
    ///
    /// // Later, when no longer needed:
    /// subscription.unsubscribe()
    /// ```
    ///
    /// - SeeAlso: ``Subscription``, ``Dispatcher``
    @discardableResult
    public func onValueChanged(_ change: @escaping ([Property]) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }
}
