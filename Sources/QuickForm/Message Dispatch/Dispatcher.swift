// Dispatcher.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-29 04:17 GMT.

import Foundation

private struct ConcreteSubscription: Subscription {
    private let _unsubscribe: () -> Void

    init(unsubscribe: @escaping () -> Void) {
        _unsubscribe = unsubscribe
    }

    func unsubscribe() {
        _unsubscribe()
    }
}

/// A type-safe event dispatcher that enables publish-subscribe communication between components.
///
/// `Dispatcher` provides a decoupled way for components to communicate through events.
/// In QuickForm, it's primarily used internally by form view models to notify subscribers
/// when field values change, enabling reactive form behaviors and field dependencies.
///
/// ## Features
/// - Type-safe event publishing and subscription
/// - Memory-safe subscription management (prevents retain cycles)
/// - Support for multiple subscribers for the same event type
/// - Used internally by QuickForm for value change notifications
///
/// ## QuickForm Usage
///
/// In QuickForm, you typically interact with `Dispatcher` indirectly through the
/// `onValueChanged` method on form view models:
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
///     @PropertyEditor(keyPath: \Address.state)
///     var state = OptionalPickerFieldViewModel(
///         type: CountryState?.self,
///         allValues: [],
///         title: "State"
///     )
///
///     @PostInit
///     func configure() {
///         // Set up field dependencies using onValueChanged
///         country.onValueChanged { [weak self] newCountry in
///             self?.state.allValues = newCountry.states
///             self?.state.value = nil
///         }
///     }
/// }
/// ```
///
/// ## Advanced Field Dependencies
///
/// Complex form logic with multiple field dependencies:
///
/// ```swift
/// @QuickForm(Prescription.self)
/// class PrescriptionEditModel: Validatable {
///     @PropertyEditor(keyPath: \Prescription.medication)
///     var medication: MedicationBuilder
///
///     @PropertyEditor(keyPath: \Prescription.dispensePackage)
///     var dispensePackage = OptionalPickerFieldViewModel<DispensePackage>(
///         type: DispensePackage?.self,
///         allValues: [],
///         title: "Package"
///     )
///
///     @PropertyEditor(keyPath: \Prescription.dispense)
///     var dispense = FormattedFieldViewModel(
///         type: Int?.self,
///         format: OptionalFormat(format: .number),
///         title: "Dispense"
///     )
///
///     @PostInit
///     func configure() {
///         // When dosage form changes, update the dispense format
///         medication.dosageForm.onValueChanged { [weak self] newValue in
///             if let form = newValue?.form {
///                 self?.dispense.format = OptionalFormat(format: .dosageForm(form))
///             }
///         }
///
///         // When package changes, update dispense value
///         dispensePackage.onValueChanged { [weak self] newValue in
///             self?.dispense.value = newValue
///         }
///     }
/// }
/// ```
///
/// ## Direct Usage Example
///
/// While typically used internally, you can also use `Dispatcher` directly:
///
/// ```swift
/// // Create a dispatcher
/// let dispatcher = Dispatcher()
///
/// // Subscribe to value changes
/// let subscription = dispatcher.subscribe { (newValue: String) in
///     print("Value changed to: \(newValue)")
/// }
///
/// // Publish a change
/// dispatcher.publish("New Value")
///
/// // Clean up when done
/// subscription.unsubscribe()
/// ```
public class Dispatcher {
    private protocol AnyHandler {}
    private struct TypedHandler<T>: AnyHandler {
        let id: UUID
        let handler: (T) -> Void
    }

    private var registrations: [AnyHandler]

    /// Creates a new, empty dispatcher.
    public init() {
        registrations = []
    }

    /// Publishes an event to all subscribers of the matching type.
    ///
    /// This method delivers the event to all registered handlers that match the event's type.
    /// If there are no matching subscribers, this method has no effect.
    ///
    /// - Parameter event: The event to publish to subscribers.
    ///
    /// - Note: Event delivery happens synchronously on the calling thread.
    public func publish<T>(_ event: T) {
        for typedHandler in registrations {
            if let typedHandler = typedHandler as? TypedHandler<T> {
                typedHandler.handler(event)
            }
        }
    }

    /// Registers a handler to receive events of a specific type.
    ///
    /// This method creates a subscription that will invoke the provided handler
    /// whenever an event of matching type is published through this dispatcher.
    ///
    /// - Parameter handler: A closure that will be called with events of type `T`.
    ///   The handler is marked as `@Sendable` to ensure thread safety.
    ///
    /// - Returns: A `Subscription` object that can be used to cancel this subscription.
    ///
    /// - Note: The dispatcher holds a weak reference to `self` in the returned subscription
    ///   to avoid retain cycles.
    public func subscribe<T>(handler: @escaping @Sendable (T) -> Void) -> Subscription {
        let key = UUID()

        let typedHandler = TypedHandler(id: key, handler: handler)

        registrations.append(typedHandler)

        return ConcreteSubscription { [weak self] in
            if let index = self?.registrations.firstIndex(where: {
                if let typedHandler = $0 as? TypedHandler<T>,
                   typedHandler.id == key {
                    true
                } else {
                    false
                }
            }) {
                self?.registrations.remove(at: index)
            }
        }
    }
}
