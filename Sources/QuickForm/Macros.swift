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
///         value: "",
///         title: "First Name:",
///         placeholder: "John",
///         validation: .of(.required("First name is required"))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         value: "",
///         title: "Last Name:",
///         placeholder: "Doe",
///         validation: .of(.required("Last name is required"))
///     )
///
///     @PropertyEditor(keyPath: \Person.dateOfBirth)
///     var birthday = FormFieldViewModel(
///         value: Date(),
///         title: "Birthday:",
///         placeholder: "Select date"
///     )
/// }
/// ```
///
/// ### Advanced Form with Dependencies and Custom Validation
///
/// ```swift
/// @QuickForm(Employee.self)
/// class EmployeeFormModel: Validatable {
///     @PropertyEditor(keyPath: \Employee.name)
///     var name = FormFieldViewModel<String>(
///         value: "",
///         title: "Name:",
///         validation: .of(.required("Name is required"))
///     )
///
///     @PropertyEditor(keyPath: \Employee.department)
///     var department = PickerFieldViewModel(
///         value: nil,
///         allValues: [],
///         title: "Department:"
///     )
///
///     @PropertyEditor(keyPath: \Employee.position)
///     var position = PickerFieldViewModel(
///         value: nil,
///         allValues: [],
///         title: "Position:"
///     )
///
///     @PostInit
///     func setupDependencies() {
///         // Load departments from a service
///         department.allValues = DepartmentService.shared.getAllDepartments()
///
///         // When department changes, update available positions
///         department.onValueChanged { [weak self] newDepartment in
///             guard let self = self, let dept = newDepartment else { return }
///             self.position.allValues = PositionService.shared.getPositions(forDepartment: dept)
///             self.position.value = nil
///         }
///
///         // Add custom validation rule
///         addCustomValidationRule { [weak self] in
///             guard let self = self else { return .success }
///             if self.department.value != nil && self.position.value == nil {
///                 return .failure("Please select a position for the chosen department")
///             }
///             return .success
///         }
///     }
/// }
/// ```
///
/// In this example, `@QuickForm` is applied to `PersonEditModel` and `EmployeeFormModel`, generating the necessary code to manage forms
/// for editing `Person` and `Employee` objects respectively. The `@PropertyEditor` property wrapper is used in conjunction with `@QuickForm`
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
    named(onValueChanged)
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
///         value: "",
///         title: "First Name:",
///         placeholder: "John",
///         validation: .of(.required("First name is required"))
///     )
///
///     @PropertyEditor(keyPath: \Person.familyName)
///     var lastName = FormFieldViewModel(
///         value: "",
///         title: "Last Name:",
///         placeholder: "Doe",
///         validation: .of(.required("Last name is required"))
///     )
/// }
/// ```
///
/// ### Working with Different Field Types
///
/// ```swift
/// @QuickForm(Order.self)
/// class OrderFormModel: Validatable {
///     // Text field for string property
///     @PropertyEditor(keyPath: \Order.orderNumber)
///     var orderNumber = FormFieldViewModel<String>(
///         value: "",
///         title: "Order #:",
///         validation: .of(.pattern("^ORD-\\d{6}$", "Must be in format ORD-123456"))
///     )
///
///     // Toggle field for boolean property
///     @PropertyEditor(keyPath: \Order.isPriority)
///     var priority = FormFieldViewModel<Bool>(
///         value: false,
///         title: "Priority Order"
///     )
///
///     // Picker field for enum property
///     @PropertyEditor(keyPath: \Order.status)
///     var status = PickerFieldViewModel<OrderStatus>(
///         value: .pending,
///         allValues: OrderStatus.allCases,
///         title: "Status:"
///     )
///
///     // Optional text field for optional property
///     @PropertyEditor(keyPath: \Order.notes)
///     var notes = FormFieldViewModel<String?>(
///         value: nil,
///         title: "Notes:",
///         placeholder: "Optional notes"
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
/// @QuickForm(Product.self)
/// class ProductFormModel: Validatable {
///     @Dependency
///     var dependencies: Dependencies
///
///     @PropertyEditor(keyPath: \Address.country)
///     var country: AsyncPickerFieldViewModel<String?>
///
///     @OnInit
///     func onInit() {
///         // Configure dependencies
///         country = AsyncPickerFieldViewModel(
///             type: String?.self,
///             placeholder: "Select Country...",
///             validation: .of(.required()),
///             valuesProvider: { [weak self] query in
///                 guard let self else { return [] }
///                 return try await dependencies.countryLoader.loadCountries(query: query)
///             },
///             queryBuilder: { $0 ?? "" }
///         )
/// }
/// ```
///
/// In this example, the `onInit()` method is marked with `@OnInit` and
/// will be called during the initialization of the `ProductFormModel` instance. `ProductFormModel.country` property is
/// initialized inside this method using provided dependencies.
@attached(peer)
public macro OnInit() = #externalMacro(module: "QuickFormMacros", type: "OnInitMacro")

/// A macro that marks a method to be executed after the class is initialized.
///
/// The `@PostInit` macro allows you to define a method that will be automatically called
/// after all properties of a `@QuickForm` class have been initialized. This is useful for
/// setting up dependencies between form fields, configuring initial values, or performing
/// other setup tasks that require all properties to be initialized first.
///
/// ## Example Usage:
///
/// ```swift
/// @QuickForm(Product.self)
/// class ProductFormModel: Validatable {
///     @Dependency
///     var dependencies: Dependencies
///
///     @PropertyEditor(keyPath: \Address.country)
///     var country: AsyncPickerFieldViewModel<String?>
///
///     @OnInit
///     func onInit() {
///         // Configure dependencies
///         country = AsyncPickerFieldViewModel(
///             type: String?.self,
///             placeholder: "Select Country...",
///             validation: .of(.required()),
///             valuesProvider: { [weak self] query in
///                 guard let self else { return [] }
///                 return try await dependencies.countryLoader.loadCountries(query: query)
///             },
///             queryBuilder: { $0 ?? "" }
///         )
/// }
/// ```
/// In this example, the `ProductFormModel.dependencies` property is marked with `@Dependency`.
/// This will modify init method of `ProductFormModel` to look like: `init(value: Product, dependencies: Dependencies)`
/// Dependencies will be injected during init, so other properties depending on them can be initialized inside method marked
/// with `@OnInit`.
@attached(peer)
public macro Dependency() = #externalMacro(module: "QuickFormMacros", type: "DependencyMacro")
