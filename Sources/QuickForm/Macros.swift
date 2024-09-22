// Macros.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Observation

/// A macro that generates boilerplate code for form management.
///
/// The `@QuickForm` macro simplifies the creation of form-based user interfaces by automatically generating
/// the necessary infrastructure for data binding, validation, and state management. When applied to a class,
/// it creates properties and methods that facilitate the connection between your data model and the UI.
///
/// The macro generates:
/// - A `model` property to store and access the underlying data model.
/// - An `update()` method to synchronize the form fields with the model.
/// - An initializer that sets up the initial state and bindings.
/// - Methods for tracking changes and managing observations.
/// - If the class conforms to `Validatable`, it also generates validation-related properties and methods.
///
/// - Parameter type: The type of the data model that this form represents.
///
/// - Note: The class decorated with `@QuickForm` should also conform to `Validatable`
/// if you want to use the built-in validation features.
///
/// ## Example Usage:
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         value: "",
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         value: "",
///         title: "Last Name:",
///         placeholder: "Doe",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.dateOfBirth)
///     var birthday = FormFieldViewModel(
///         value: Date(),
///         title: "Birthday:",
///         placeholder: "1980-01-01"
///     )
/// }
/// ```
///
/// In this example, `@QuickForm` is applied to `PersonEditModel`, generating the necessary code to manage a form
/// for editing a `Person` object. The `@PropertyEditor` property wrapper is used in conjunction with `@QuickForm`
/// to create bindings between individual form fields and properties of the `Person` model.
@attached(
    member,
    names: named(init),
    named(model),
    named(_model),
    named(track),
    named(_$observationRegistrar),
    named(access),
    named(withMutation),
    named(update),
    named(validationResult),
    named(_validationResult),
    named(validate),
    named(customValidationRules),
    named(addCustomValidationRule)
)
@attached(extension, conformances: Observable)
public macro QuickForm<T>(_ type: T.Type) = #externalMacro(module: "QuickFormMacros", type: "QuickFormMacro")

/// A property wrapper that creates a binding between a form field and a property in your data model.
///
/// The `@PropertyEditor` macro simplifies the process of connecting individual form fields to properties
/// in your data model. When used within a class decorated with `@QuickForm`, it automatically sets up
/// the necessary infrastructure for two-way data binding and change tracking.
///
/// This macro generates:
/// - A backing storage property prefixed with an underscore.
/// - Getter and setter methods that handle access tracking and mutation.
/// - A `_modify` method for supporting mutable access to the property.
///
/// - Parameter keyPath: A key path that points to the corresponding property in the data model.
///
/// - Note: This macro should be used in conjunction with `@QuickForm` for full functionality.
///
/// ## Example Usage:
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         value: "",
///         title: "First Name:",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         value: "",
///         title: "Last Name:",
///         placeholder: "Doe",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
/// }
/// ```
///
/// In this example, `@PropertyEditor` is applied to `firstName` and `lastName` properties,
/// creating bindings between these form fields and the corresponding properties of the `Person` model.
/// The `keyPath` parameter specifies which property in the `Person` model each field is associated with.
///
/// - Important: The type of the property decorated with `@PropertyEditor` should be compatible with
///   the type of the property it's binding to in the data model. Typically, this will be a `FormFieldViewModel`
///   or another type that conforms to `ValueEditor`.
@attached(accessor, names: named(init), named(get), named(set), named(_modify))
@attached(peer, names: prefixed(`_`))
public macro PropertyEditor(keyPath: Any) = #externalMacro(module: "QuickFormMacros", type: "PropertyEditorMacro")

@attached(peer)
public macro PostInit() = #externalMacro(module: "QuickFormMacros", type: "PostInitMacro")
