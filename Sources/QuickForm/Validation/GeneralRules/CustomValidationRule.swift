// CustomValidationRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:25 GMT.

/// A generic validation rule that allows custom validation logic through closures.
///
/// `CustomValidationRule` is a flexible validation rule that accepts a custom validation closure,
/// allowing you to implement any validation logic you need. This is particularly useful when
/// the built-in validation rules don't meet your specific requirements, or when you need to
/// implement complex business logic validation.
///
/// ## Features
/// - Accepts any custom validation logic through closures
/// - Generic over any type, making it extremely flexible
/// - Can be used to implement complex business rules
/// - Easily composable with other validation rules
/// - Perfect for one-off or highly specific validation needs
///
/// ## Example
///
/// ```swift
/// @QuickForm(PersonForm.self)
/// class PersonFormModel: Validatable {
///     @PropertyEditor(keyPath: \PersonForm.age)
///     var age = FormFieldViewModel(
///         type: Int.self,
///         title: "Age",
///         placeholder: "25",
///         validation: .of(.custom { age in
///             if age >= 18 && age <= 65 {
///                 return .success
///             } else {
///                 return .failure("Age must be between 18 and 65")
///             }
///         })
///     )
///
///     @PropertyEditor(keyPath: \PersonForm.password)
///     var password = FormFieldViewModel(
///         type: String.self,
///         title: "Password:",
///         placeholder: "P@$$w0rd",
///         validation: .combined(
///             .notEmpty,
///             .minLength(8),
///             .custom { password in
///                 let hasUppercase = password.contains { $0.isUppercase }
///                 let hasLowercase = password.contains { $0.isLowercase }
///                 let hasDigit = password.contains { $0.isNumber }
///                 let hasSpecial = password.contains { "!@#$%^&*()".contains($0) }
///                 
///                 if hasUppercase && hasLowercase && hasDigit && hasSpecial {
///                     return .success
///                 } else {
///                     return .failure("Password must contain uppercase, lowercase, digit, and special character")
///                 }
///             }
///         )
///     )
/// }
///
/// let model = PersonFormModel(model: PersonForm())
/// model.age.value = 17
/// let ageResult = model.age.validate()
/// // ageResult will be .failure("Age must be between 18 and 65")
///
/// model.age.value = 25
/// let updatedAgeResult = model.age.validate()
/// // updatedAgeResult will be .success
/// ```
public struct CustomValidationRule<T>: ValidationRule {
    /// The custom validation closure.
    ///
    /// This closure contains the user-defined validation logic and is called
    /// whenever the `validate(_:)` method is invoked.
    let validate: (T) -> ValidationResult

    /// Initializes a new `CustomValidationRule` with the provided validation closure.
    ///
    /// - Parameter validate: A closure that takes a value of type `T` and returns a `ValidationResult`.
    ///   This closure should contain your custom validation logic.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ageRule = CustomValidationRule<Int> { age in
    ///     if age >= 0 && age <= 120 {
    ///         return .success
    ///     } else {
    ///         return .failure("Age must be between 0 and 120")
    ///     }
    /// }
    /// ```
    public init(_ validate: @escaping (T) -> ValidationResult) {
        self.validate = validate
    }

    /// Validates the given value using the custom validation closure.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: A `ValidationResult` returned by the custom validation closure.
    public func validate(_ value: T) -> ValidationResult {
        validate(value)
    }
}

public extension ValidationRule {
    /// A convenience static method to create a `CustomValidationRule` wrapped in `AnyValidationRule`.
    ///
    /// This allows for more readable code when using custom validation rules, especially
    /// in combination with other rules.
    ///
    /// - Parameter validate: A closure that takes a value of type `T` and returns a `ValidationResult`.
    /// - Returns: An `AnyValidationRule<T>` wrapping the custom validation rule.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = AnyValidationRule.combined(
    ///     .notEmpty,
    ///     .custom { value in
    ///         value.hasPrefix("valid") ? .success : .failure("Must start with 'valid'")
    ///     }
    /// )
    /// ```
    static func custom<T>(_ validate: @escaping (T) -> ValidationResult) -> AnyValidationRule<T> where Self == AnyValidationRule<T> {
        AnyValidationRule<T>(CustomValidationRule<T>(validate))
    }
}
