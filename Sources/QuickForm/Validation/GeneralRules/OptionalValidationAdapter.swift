// OptionalValidationAdapter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 17:40 GMT.

import Foundation

/// An adapter that applies validation rules to optional values.
///
/// `OptionalValidationAdapter` is an internal adapter struct that wraps existing validation rules
/// to work with optional values. It allows validation rules designed for non-optional types
/// to be applied to optional values, with configurable behavior for `nil` values.
///
/// This adapter is primarily used internally by the `OptionalRule` enum to provide
/// convenient methods for validating optional values.
///
/// ## Features
/// - Adapts non-optional validation rules to work with optional values
/// - Configurable behavior for `nil` values (can be treated as valid or invalid)
/// - Supports both "if present" and "required" validation modes
/// - Maintains type safety while providing flexibility
///
/// ## Internal Usage
///
/// This struct is typically not used directly but through the `OptionalRule` enum:
///
/// ```swift
/// // Instead of using OptionalValidationAdapter directly:
/// // let adapter = OptionalValidationAdapter(EmailRule(), requireNonNil: false)
///
/// // Use the convenient OptionalRule methods:
/// let validation = OptionalRule.ifPresent(.email)
/// let requiredValidation = OptionalRule.required(.email)
/// ```
struct OptionalValidationAdapter<Rule: ValidationRule>: ValidationRule {
    /// The underlying validation rule that will be applied to non-nil values.
    private let rule: Rule
    
    /// Whether nil values should be treated as validation failures.
    private let requireNonNil: Bool

    /// Initializes a new `OptionalValidationAdapter`.
    ///
    /// - Parameters:
    ///   - rule: The validation rule to apply to non-nil values.
    ///   - requireNonNil: Whether nil values should be treated as validation failures.
    ///     When `false` (default), nil values pass validation. When `true`, nil values fail validation.
    init(
        _ rule: Rule,
        requireNonNil: Bool = false
    ) {
        self.rule = rule
        self.requireNonNil = requireNonNil
    }

    /// Validates the given optional value.
    ///
    /// The behavior depends on whether the value is nil and the `requireNonNil` setting:
    /// - If the value is nil and `requireNonNil` is `false`, returns `.success`
    /// - If the value is nil and `requireNonNil` is `true`, returns `.failure` with "This field is required"
    /// - If the value is non-nil, applies the underlying rule to the unwrapped value
    ///
    /// - Parameter value: The optional value to validate.
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    func validate(_ value: Rule.Value?) -> ValidationResult {
        guard let value else {
            return requireNonNil ? .failure("This field is required") : .success
        }

        return rule.validate(value)
    }
}

/// A utility enum providing convenient methods for creating optional validation rules.
///
/// `OptionalRule` provides static methods that create validation rules for optional values,
/// using the `OptionalValidationAdapter` internally. This enum makes it easy to apply
/// existing validation rules to optional fields in your forms.
///
/// ## Usage Patterns
///
/// There are two main patterns for validating optional values:
/// 1. **If Present**: Validate only if the value is non-nil, ignore nil values
/// 2. **Required**: Require a non-nil value and then validate it
///
/// ## Example
///
/// ```swift
/// @QuickForm(ProfileForm.self)
/// class ProfileFormModel: Validatable {
///     @PropertyEditor(keyPath: \ProfileForm.bio)
///     var bio = FormFieldViewModel(
///         type: String?.self,
///         title: "Bio",
///         placeholder: "Tell us about yourself...",
///         validation: .of(OptionalRule.ifPresent(.maxLength(256)))
///     )
///
///     @PropertyEditor(keyPath: \ProfileForm.email)
///     var email = FormFieldViewModel(
///         type: String?.self,
///         title: "Email",
///         placeholder: "email@example.com",
///         validation: .of(OptionalRule.required(.email))
///     )
/// }
///
/// let model = ProfileFormModel(model: ProfileForm())
/// 
/// // Bio is optional - nil passes validation
/// model.bio.value = nil
/// let bioResult = model.bio.validate()
/// // bioResult will be .success
///
/// // Bio is optional - but if provided, must meet length requirements
/// model.bio.value = "Very long bio that exceeds the maximum character limit..."
/// let longBioResult = model.bio.validate()
/// // longBioResult will be .failure("This field must not exceed 256 characters")
///
/// // Email is required - nil fails validation
/// model.email.value = nil
/// let emailResult = model.email.validate()
/// // emailResult will be .failure("This field is required")
///
/// // Email is required and must be valid format
/// model.email.value = "invalid-email"
/// let invalidEmailResult = model.email.validate()
/// // invalidEmailResult will be .failure("Please enter a valid email address")
/// ```
public enum OptionalRule {
    /// Creates a validation rule that applies the given rule to an optional value, if present.
    ///
    /// When the value is `nil`, validation succeeds. When the value is non-nil,
    /// the provided rule is applied to the unwrapped value.
    ///
    /// This is useful for optional fields where you want to validate the format
    /// or constraints of the value only when it's provided.
    ///
    /// - Parameter rule: The validation rule to apply to non-nil values.
    /// - Returns: An `AnyValidationRule` that validates optional values.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Optional field that validates length only if provided
    /// let validation = OptionalRule.ifPresent(.maxLength(100))
    /// 
    /// // nil passes validation
    /// validation.validate(nil) // .success
    /// 
    /// // Non-nil values are validated
    /// validation.validate("short") // .success
    /// validation.validate("very long text...") // may fail if > 100 chars
    /// ```
    public static func ifPresent<R: ValidationRule>(_ rule: R) -> AnyValidationRule<R.Value?> {
        AnyValidationRule(OptionalValidationAdapter(rule))
    }

    /// Creates a validation rule that requires a non-nil value and applies the given rule.
    ///
    /// When the value is `nil`, validation fails with "This field is required".
    /// When the value is non-nil, the provided rule is applied to the unwrapped value.
    ///
    /// This is useful for fields that are technically optional types but are
    /// required by your business logic.
    ///
    /// - Parameter rule: The validation rule to apply to non-nil values.
    /// - Returns: An `AnyValidationRule` that validates required optional values.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Required field that must also pass email validation
    /// let validation = OptionalRule.required(.email)
    /// 
    /// // nil fails validation
    /// validation.validate(nil) // .failure("This field is required")
    /// 
    /// // Non-nil values must pass the underlying rule
    /// validation.validate("invalid") // .failure("Please enter a valid email address")
    /// validation.validate("user@example.com") // .success
    /// ```
    public static func required<R: ValidationRule>(
        _ rule: R
    ) -> AnyValidationRule<R.Value?> {
        AnyValidationRule(OptionalValidationAdapter(rule, requireNonNil: true))
    }
}
