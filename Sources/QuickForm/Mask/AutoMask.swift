// AutoMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 04:59 GMT.

import Foundation

/// A protocol that defines how text should be automatically formatted while being edited.
///
/// ``AutoMask`` provides a standardized way to format user input text in real-time,
/// ensuring consistent presentation of data such as phone numbers, credit cards,
/// social security numbers, and other formatted text inputs.
///
/// ## Features
/// - Real-time formatting of user input
/// - Character validation to prevent invalid input
/// - Maintains consistent formatting across the application
/// - Works seamlessly with ``FormFieldViewModel`` input fields
///
/// ## Example
///
/// ```swift
/// struct PhoneNumberMask: AutoMask {
///     func apply(to text: String) -> String {
///         let digits = text.filter { $0.isNumber }
///         guard digits.count > 0 else { return "" }
///
///         switch digits.count {
///         case 1...3:
///             return digits
///         case 4...6:
///             return "\(digits.prefix(3))-\(digits.dropFirst(3))"
///         case 7...10:
///             return "\(digits.prefix(3))-\(digits.dropFirst(3).prefix(3))-\(digits.dropFirst(6))"
///         default:
///             return String(digits.prefix(10))
///         }
///     }
///
///     func isAllowed(character: Character) -> Bool {
///         return character.isNumber
///     }
/// }
///
/// // Usage in a form field
/// @QuickForm(ContactForm.self)
/// class ContactFormModel: Validatable {
///     @PropertyEditor(keyPath: \ContactForm.phoneNumber)
///     var phoneNumber = FormFieldViewModel(
///         type: String.self,
///         title: "Phone:",
///         placeholder: "Enter phone number",
///         mask: PhoneNumberMask(),
///         validation: .of(.usPhoneNumber)
///     )
/// }
/// ```
///
/// ## Common Implementations
///
/// - Phone number masking (e.g., (123) 456-7890)
/// - Credit card masking (e.g., 1234 5678 9012 3456)
/// - Date masking (e.g., MM/DD/YYYY)
/// - Social security number masking (e.g., 123-45-6789)
///
/// - SeeAlso: ``FormFieldViewModel``, ``USPhoneNumberFormatStyle``
public protocol AutoMask {
    /// Applies the mask to the input text.
    ///
    /// This method takes the raw text entered by the user and formats it
    /// according to the mask's rules. It should handle any input length
    /// and return a properly formatted string.
    ///
    /// - Parameter text: The raw text entered by the user
    /// - Returns: The formatted text according to the mask
    ///
    /// ## Example
    ///
    /// ```swift
    /// func apply(to text: String) -> String {
    ///     let digits = text.filter { $0.isNumber }
    ///     if digits.count >= 10 {
    ///         let areaCode = digits.prefix(3)
    ///         let middle = digits.dropFirst(3).prefix(3)
    ///         let last = digits.dropFirst(6).prefix(4)
    ///         return "(\(areaCode)) \(middle)-\(last)"
    ///     }
    ///     return text
    /// }
    /// ```
    func apply(to text: String) -> String

    /// Determines if a character is allowed by the mask.
    ///
    /// This method validates whether a specific character should be
    /// accepted as input. It's typically used to filter user input
    /// before applying the mask.
    ///
    /// - Parameter character: The character to check
    /// - Returns: Whether the character is allowed
    ///
    /// ## Example
    ///
    /// ```swift
    /// func isAllowed(character: Character) -> Bool {
    ///     return character.isNumber || character == "-"
    /// }
    /// ```
    func isAllowed(character: Character) -> Bool
}
