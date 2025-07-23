// Macros.swift
// Copyright (c) 2025 Moroverse
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
/// - If the class conforms to ``Validatable``, it also generates validation-related properties and methods.
///
/// - Parameter type: The type of the data model that this form represents.
///
/// - Note: The class decorated with `@QuickForm` should also conform to ``Validatable``
/// if you want to use the built-in validation features.
///
/// ## Example Usage:
///
/// ### Basic Form Model
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         type: String.self,
///         title: "Last Name",
///         placeholder: "Anderson",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.dateOfBirth)
///     var birthday = FormFieldViewModel(
///         type: Date.self,
///         title: "Date of Birth"
///     )
/// }
/// ```
///
/// ### Form with Field Dependencies
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
///         title: "State",
///         placeholder: "Select State"
///     )
///
///     @PostInit
///     func configure() {
///         // When country changes, update available states
///         country.onValueChanged { [weak self] newCountry in
///             self?.state.allValues = newCountry.states
///             self?.state.value = nil
///             
///             // Conditional validation
///             if self?.state.allValues.isEmpty == true {
///                 self?.state.validation = nil
///             } else {
///                 self?.state.validation = .of(.required())
///             }
///         }
///     }
/// }
/// ```
///
/// In these examples, `@QuickForm` is applied to generate the necessary code to manage forms
/// for editing `Person` and `Address` objects respectively. The `@PropertyEditor` property wrapper is used in conjunction with `@QuickForm`
/// to create bindings between individual form fields and properties of the model.
@attached(
    member,
    names: named(init),
    named(value),
    named(_value),
    named(track),
    named(_$observationRegistrar),
    named(access),
    named(withMutation),
    named(update),
    named(validationResult),
    named(_validationResult),
    named(validate),
    named(customValidationRules),
    named(addCustomValidationRule),
    named(dispatcher),
    named(onValueChanged),
    arbitrary
)
@attached(extension, conformances: Observable, ObservableValueEditor)
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
/// ### Basic Property Binding
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         type: String.self,
///         title: "Last Name",
///         placeholder: "Anderson",
///         validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
///     )
/// }
/// ```
///
/// ### Working with Different Field Types
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     // Text field for string property
///     @PropertyEditor(keyPath: \Person.givenName)
///     var firstName = FormFieldViewModel(
///         type: String.self,
///         title: "First Name",
///         placeholder: "John",
///         validation: .combined(.notEmpty, .maxLength(50))
///     )
///
///     // Toggle field for boolean property
///     @PropertyEditor(keyPath: \Person.isEstablished)
///     var isEstablished = FormFieldViewModel(
///         type: Bool.self,
///         title: "Established Customer"
///     )
///
///     // Picker field for enum property
///     @PropertyEditor(keyPath: \Person.sex)
///     var sex = PickerFieldViewModel(
///         type: Person.Sex.self,
///         allValues: Person.Sex.allCases,
///         title: "Sex"
///     )
///
///     // Optional formatted field
///     @PropertyEditor(keyPath: \Person.phone)
///     var phone = FormattedFieldViewModel(
///         type: String?.self,
///         format: OptionalFormat(format: .usPhoneNumber(.parentheses)),
///         title: "Phone",
///         placeholder: "(123) 456-7890"
///     )
/// }
/// ```
///
/// In these examples, `@PropertyEditor` is applied to form field properties,
/// creating bindings between these fields and the corresponding properties of the model.
/// The `keyPath` parameter specifies which property in the model each field is associated with.
///
/// - Important: The type of the property decorated with `@PropertyEditor` should be compatible with
///   the type of the property it's binding to in the data model. Typically, this will be a ``FormFieldViewModel``
///   or another type that conforms to ``ValueEditor``.
@attached(accessor, names: named(init), named(get), named(set), named(_modify))
@attached(peer, names: prefixed(`_`))
public macro PropertyEditor(keyPath: Any) = #externalMacro(module: "QuickFormMacros", type: "PropertyEditorMacro")

/// A macro that marks a method to be executed after the class is initialized.
///
/// The `@PostInit` macro allows you to define a method that will be automatically called
/// after all properties of a `@QuickForm` class have been initialized. This is useful for
/// setting up dependencies between form fields, configuring validation rules, or performing
/// other setup tasks that require all properties to be initialized first.
///
/// ## Example Usage:
///
/// ```swift
/// @QuickForm(AdditionalInfo.self)
/// class AdditionalInfoModel {
///
///     @PropertyEditor(keyPath: \AdditionalInfo.resume)
///     var resume: FormFieldViewModel<URL?>
///
///     @PropertyEditor(keyPath: \AdditionalInfo.coverLetter)
///     var coverLetter = FormFieldViewModel<String?>(
///         value: nil,
///         title: "Cover Letter",
///         placeholder: "Enter your cover letter"
///     )
///
///     @PostInit
///     func configure() {
///         // Set up validation that depends on other properties
///         resume.validation = .of(.custom { [weak self] _ in
///             if let uploadErrorMessage = self?.uploadErrorMessage {
///                 .failure(uploadErrorMessage)
///             } else {
///                 .success
///             }
///         })
///
///         // Configure field dependencies and event handlers
///         coverLetter.onValueChanged { [weak self] newValue in
///             guard let self = self else { return }
///             // Update other fields based on this change
///             updateRelatedFields(basedOn: newValue)
///         }
///     }
/// }
/// ```
///
/// In this example, the `configure()` method is marked with `@PostInit` and
/// will be called automatically after the `AdditionalInfoModel` instance is fully initialized.
/// This allows setting up complex validation rules that require
/// all properties to be properly initialized.
@attached(peer)
public macro PostInit() = #externalMacro(module: "QuickFormMacros", type: "PostInitMacro")

/// A macro that marks a method to be executed during initialization.
///
/// The `@OnInit` macro allows you to define a method that will be automatically called
/// during the initialization process of a `@QuickForm` class. This is useful for performing
/// setup tasks that need to happen as part of the initialization, such as setting default values
/// or configuring properties before the instance is fully initialized.
///
/// ## Example Usage:
///
/// ```swift
/// @QuickForm(Applicant.self)
/// class ApplicationFormModel {
///     @Dependency
///     var dependencies: Dependencies
///
///     @PropertyEditor(keyPath: \Applicant.personalInformation)
///     var personalInformation: PersonalInformationModel
///
///     @OnInit
///     func onInit() {
///         // Initialize fields using injected dependencies
///         personalInformation = PersonalInformationModel(
///             value: .sample,
///             dependencies: dependencies.addressModelDependencies
///         )
///     }
/// }
/// ```
///
/// In this example, the `onInit()` method is marked with `@OnInit` and
/// will be called during the initialization of the `ApplicationFormModel` instance. Properties that depend on injected dependencies
/// are initialized inside this method.
@attached(peer)
public macro OnInit() = #externalMacro(module: "QuickFormMacros", type: "OnInitMacro")

/// A macro that marks a property for dependency injection.
///
/// The `@Dependency` macro is used to mark properties that should be injected as dependencies
/// when creating an instance of a `@QuickForm` class. Properties marked with this macro become
/// required parameters in the generated initializer, allowing for clean dependency injection.
///
/// ## Example Usage:
///
/// ```swift
/// @QuickForm(Applicant.self)
/// class ApplicationFormModel {
///     @Dependency
///     var dependencies: Dependencies
///
///     @PropertyEditor(keyPath: \Applicant.personalInformation)
///     var personalInformation: PersonalInformationModel
///
///     @OnInit
///     func onInit() {
///         // Use injected dependencies to initialize properties
///         personalInformation = PersonalInformationModel(
///             value: .sample,
///             dependencies: dependencies.addressModelDependencies
///         )
///     }
/// }
///
/// // Usage: dependencies become required parameters
/// let model = ApplicationFormModel(
///     value: applicant,
///     dependencies: dependencies
/// )
/// ```
///
/// In this example, the `dependencies` property is marked with `@Dependency`,
/// which modifies the generated initializer to require it as a parameter.
@attached(peer)
public macro Dependency() = #externalMacro(module: "QuickFormMacros", type: "DependencyMacro")

/// A macro that generates observation tracking code for a property.
///
/// `@StateObserved` transforms a simple property declaration into a fully observable property
/// with proper observation tracking. This macro provides custom state observation capabilities
/// for QuickForm properties that need fine-grained change tracking.
///
/// The macro generates:
/// - A private backing storage property with underscore prefix
/// - Custom accessors with observation tracking
/// - Proper initialization, getter, setter, and `_modify` accessors
/// - Integration with the observation registrar for change notifications
///
/// ## Example Usage:
///
/// ### Basic Property Tracking
///
/// ```swift
/// @Observable
/// class FormModel {
///     @StateObserved
///     var formState: FormState = .idle
///
///     @StateObserved
///     var isLoading: Bool = false
/// }
/// ```
///
/// ### Generated Code
///
/// For the property `var formState: FormState = .idle`, the macro generates:
///
/// ```swift
/// var formState: FormState {
///     @storageRestrictions(initializes: _formState)
///     init(initialValue) {
///         _formState = initialValue
///     }
///     get {
///         access(keyPath: \.formState)
///         return _formState
///     }
///     set {
///         withMutation(keyPath: \.formState) {
///             _formState = newValue
///         }
///     }
///     _modify {
///         access(keyPath: \.formState)
///         _$observationRegistrar.willSet(self, keyPath: \.formState)
///         defer {
///             _$observationRegistrar.didSet(self, keyPath: \.formState)
///         }
///         yield &_formState
///     }
/// }
///
/// private var _formState: FormState = .idle
/// ```
///
/// ### With Form Models
///
/// ```swift
/// @QuickForm(User.self)
/// class UserFormModel: Validatable {
///     @StateObserved
///     var submissionState: SubmissionState = .idle
///
///     @StateObserved
///     var validationState: ValidationState = .valid
///
///     @PropertyEditor(keyPath: \User.name)
///     var name = FormFieldViewModel(
///         value: "",
///         title: "Name:",
///         validation: .of(.required("Name is required"))
///     )
/// }
/// ```
///
/// ## Requirements
///
/// - The property must have an initial value
/// - The containing type should be marked with `@Observable` for full observation support
/// - The property type should be a concrete type (not a protocol or generic placeholder)
///
/// ## Notes
///
/// - This macro is particularly useful for tracking form state, submission status, or other
///   observable properties that need fine-grained change tracking
/// - The generated code integrates seamlessly with SwiftUI's observation system
/// - Multiple properties can be tracked independently within the same type
///
/// - Important: This macro generates accessors that depend on `access()`, `withMutation()`,
///   and `_$observationRegistrar` being available in the containing type's scope.
@attached(accessor, names: named(init), named(get), named(set), named(_modify))
@attached(peer, names: prefixed(`_`))
public macro StateObserved() = #externalMacro(module: "QuickFormMacros", type: "StateObservedMacro")
