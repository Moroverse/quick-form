// Subscription.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 04:17 GMT.

/// A token representing an active subscription to field value changes.
///
/// A `Subscription` represents the connection between a subscriber and a form field's value changes.
/// In QuickForm, when you call `onValueChanged` on form view models, you receive a `Subscription` object
/// that allows you to manage the lifecycle of that value change listener.
///
/// When a subscription is no longer needed, call ``unsubscribe()`` to stop receiving notifications
/// and prevent memory leaks by releasing any resources associated with the subscription.
///
/// ## QuickForm Example
///
/// ```swift
/// @QuickForm(Address.self)
/// class AddressEditModel: Validatable {
///     @PropertyEditor(keyPath: \Address.country)
///     var country = PickerFieldViewModel(
///         type: Country.self,
///         allValues: Country.allCases,
///         title: "Country"
///     )
///
///     @PostInit
///     func configure() {
///         // Subscribe to country changes
///         let subscription = country.onValueChanged { [weak self] newCountry in
///             self?.handleCountryChange(newCountry)
///         }
///         
///         // Store subscription if you need to unsubscribe later
///         // Usually handled automatically by QuickForm
///     }
/// }
/// ```
///
/// ## Direct Usage Example
///
/// ```swift
/// // Subscribe to field changes
/// let subscription = nameField.onValueChanged { newName in
///     print("Name changed to: \(newName)")
/// }
///
/// // Later, when no longer interested in these changes
/// subscription.unsubscribe()
/// ```
///
/// Each subscription is specific to a particular field and handler. If you subscribe
/// to multiple fields, you'll receive a separate `Subscription` object for each one.
///
/// - SeeAlso: ``Dispatcher``
public protocol Subscription {
    /// Cancels this subscription, preventing any further field change notifications from being delivered.
    ///
    /// After calling this method:
    /// - The subscriber will no longer receive value change notifications for this field
    /// - Resources associated with the subscription will be released
    /// - The field's internal dispatcher will remove the subscription from its registry
    ///
    /// It is safe to call this method multiple times, though only the first call will have an effect.
    /// In most QuickForm scenarios, subscriptions are managed automatically, but you should call 
    /// `unsubscribe()` if you manually subscribe to field changes in long-lived objects to prevent
    /// memory leaks.
    func unsubscribe()
}
