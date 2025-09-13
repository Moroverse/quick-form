// FormFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation
import Observation

/// A view model for managing a single form field's state and behavior.
///
/// `FormFieldViewModel` is a generic class that handles the data, validation, and interaction
/// logic for a form field. It conforms to both ``ObservableValueEditor`` and ``Validatable`` protocols,
/// providing a complete solution for form field management.
///
/// This is the primary view model for most form fields in QuickForm, supporting various field types like
/// text fields, toggles, steppers, and more. You typically use this class in conjunction with the
/// ``PropertyEditor`` macro within a ``QuickForm``-annotated class.
///
/// ## Features
/// - Manages the field's value, title, and placeholder
/// - Handles read-only state
/// - Provides built-in validation support
/// - Allows for custom value change handling
/// - Works with a wide range of UI components
///
/// ## Basic Example
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         type: String.self,
///         title: "Last Name:",
///         placeholder: "Anderson",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
/// }
/// ```
///
/// ## Using With SwiftUI Form Components
///
/// `FormFieldViewModel` works with various SwiftUI form components:
///
/// ### Text Field
///
/// ```swift
/// // In your view:
/// FormTextField(model.firstName)
/// ```
///
/// ### Toggle Field
///
/// ```swift
/// // Boolean property
/// @PropertyEditor(keyPath: \Person.isEstablished)
/// var isEstablished = FormFieldViewModel(
///     type: Bool.self,
///     title: "Established:"
/// )
///
/// // In your view:
/// FormToggleField(model.isEstablished)
/// ```
///
/// ### Date Picker Field
///
/// ```swift
/// // Date property
/// @PropertyEditor(keyPath: \Person.dateOfBirth)
/// var birthday = FormFieldViewModel(
///     type: Date.self,
///     title: "Birthday:",
///     placeholder: "1980-01-01"
/// )
///
/// // In your view:
/// FormDatePickerField(model.birthday)
/// ```
///
/// ## Validation
///
/// The model supports validation through the ``AnyValidationRule`` type:
///
/// ```swift
/// // Email validation (using built-in rule)
/// @PropertyEditor(keyPath: \Person.email)
/// var email = FormFieldViewModel(
///     type: String.self,
///     title: "Email",
///     placeholder: "johndoe@example.com",
///     validation: .of(.email)
/// )
/// ```
///
/// - SeeAlso: ``ObservableValueEditor``, ``Validatable``, ``FormTextField``, ``FormToggleField``
@Observable
public final class FormFieldViewModel<Property>: ObservableValueEditor, Validatable {
    /// The title of the form field.
    ///
    /// This title is typically displayed as a label beside or above the form field
    /// in the UI to identify the purpose of the field.
    public var title: LocalizedStringResource

    /// An optional placeholder text for the form field.
    ///
    /// The placeholder is displayed when the field is empty and provides guidance
    /// to the user about what kind of information should be entered.
    public var placeholder: LocalizedStringResource?

    /// The current value of the form field.
    ///
    /// When this value changes:
    /// - All subscribers registered via `onValueChanged(_:)` are notified
    /// - Validation is performed and `validationResult` is updated
    public var value: Property {
        didSet {
            if let oldH = oldValue as? AnyHashable,
               let newH = value as? AnyHashable,
               oldH == newH {
                return
            }
            dispatcher.publish(value)
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    ///
    /// When `true`, the field should not allow user edits. UI components using
    /// this view model should respect this value and render accordingly.
    public var isReadOnly: Bool

    /// The event dispatcher for value change notifications.
    private var dispatcher: Dispatcher

    /// The validation rule to apply to the field's value.
    ///
    /// This rule is evaluated whenever the `value` property changes or when
    /// `validate()` or `revalidate()` is called explicitly.
    public var validation: AnyValidationRule<Property>?

    /// The current validation state of the field.
    ///
    /// This property indicates whether the current field value meets
    /// the validation requirements.
    private(set) var validationResult: ValidationResult = .success

    /// Initializes a new instance of `FormFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial value of the form field.
    ///   - title: The title of the form field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let nameField = FormFieldViewModel(
    ///     value: "John",
    ///     title: "Name:",
    ///     placeholder: "Enter your full name",
    ///     validation: .of(.notEmpty)
    /// )
    /// ```
    public init(
        value: Property,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Property>? = nil
    ) {
        self.value = value
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        dispatcher = Dispatcher()
        validationResult = validate()
    }

    /// Sets a closure to be called when the value changes.
    ///
    /// This method allows you to respond to changes in the field's value,
    /// which is useful for implementing dependencies between fields or
    /// updating other parts of your UI in response to field changes.
    ///
    /// - Parameter change: A closure that takes the new value as its parameter.
    /// - Returns: A ``Subscription`` object that can be used to unsubscribe when needed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let subscription = nameField.onValueChanged { newName in
    ///     // Update UI or trigger other logic based on name changes
    ///     print("Name changed to: \(newName)")
    /// }
    ///
    /// // Later, when no longer needed:
    /// subscription.unsubscribe()
    /// ```
    ///
    /// - SeeAlso: ``Subscription``, ``Dispatcher``
    @discardableResult
    public func onValueChanged(_ change: @escaping (Property) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }

    /// Performs validation on the current value.
    ///
    /// This method evaluates the field's value against the validation rule
    /// provided during initialization. If no validation rule was provided,
    /// it returns `.success`.
    ///
    /// - Returns: A ``ValidationResult`` indicating whether validation succeeded or failed.
    ///
    /// - SeeAlso: ``ValidationResult``, ``AnyValidationRule``
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }

    /// Manually triggers validation and updates the validation result.
    ///
    /// This method is useful when you need to validate the field without
    /// changing its value, for example when initially loading a form.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Validate all fields in a form
    /// func validateForm() {
    ///     nameField.revalidate()
    ///     emailField.revalidate()
    ///     ageField.revalidate()
    /// }
    /// ```
    ///
    /// - Returns: The `FormFieldViewModel` instance for method chaining.
    @discardableResult
    public func revalidate() -> Self {
        validationResult = validation?.validate(value) ?? .success
        return self
    }
}

/// Extension providing convenience initializers for types that conform to ``DefaultValueProvider``.
public extension FormFieldViewModel where Property: DefaultValueProvider {
    /// Convenience initializer that uses the default value of the property type.
    ///
    /// This initializer allows you to specify the type of property instead of providing
    /// an explicit initial value. The default value is obtained from the type's implementation
    /// of ``DefaultValueProvider``.
    ///
    /// - Parameters:
    ///   - type: The type of property.
    ///   - title: The title of the form field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Creates a field with an empty string as the default value
    /// let nameField = FormFieldViewModel(
    ///     type: String.self,
    ///     title: "Name:",
    ///     placeholder: "Enter your name"
    /// )
    /// ```
    ///
    /// - SeeAlso: ``DefaultValueProvider``
    convenience init(
        type: Property.Type,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Property>? = nil
    ) {
        self.init(
            value: Property.defaultValue,
            title: title,
            placeholder: placeholder,
            isReadOnly: isReadOnly,
            validation: validation
        )
    }
}
