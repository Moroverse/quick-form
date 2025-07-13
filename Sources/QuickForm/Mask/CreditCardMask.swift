// CreditCardMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 04:59 GMT.

import Foundation

/// A mask for formatting credit card numbers as the user types.
///
/// `CreditCardMask` automatically formats input text to match standard credit card number
/// formatting with spaces between each group of 4 digits (XXXX XXXX XXXX XXXX).
///
/// ## Features
/// - Formats digits into groups of four separated by spaces
/// - Automatically filters out non-numeric characters
/// - Limits input to a valid credit card length (up to 19 digits)
/// - Works with `FormFieldViewModel` for real-time formatting
///
/// ## Example
///
/// ```swift
/// // Create a credit card field using the mask
/// @QuickForm(PaymentForm.self)
/// class PaymentFormModel: Validatable {
///     @PropertyEditor(keyPath: \PaymentForm.cardNumber)
///     var cardNumber = FormFieldViewModel(
///         type: String.self,
///         title: "Card Number:",
///         placeholder: "XXXX XXXX XXXX XXXX"
///     )
/// }
///
/// // Usage in SwiftUI view (actual pattern)
/// FormFormattedTextField(model.cardNumber, autoMask: .creditCard)
/// ```
///
/// ## Usage with Validation
///
/// For best results, pair with validation:
///
/// ```swift
/// FormFieldViewModel(
///     type: String.self,
///     title: "Card Number:",
///     validation: .combined(
///         .notEmpty,
///         .custom { value in
///             // Additional validation logic
///             let digits = value.filter(\.isNumber)
///             return digits.count >= 13 && digits.count <= 19 ? .success : .failure("Invalid card number")
///         }
///     )
/// )
/// ```
///
/// - SeeAlso: `AutoMask`, `FormFieldViewModel`, `USPhoneNumberFormatStyle`
public struct CreditCardMask: AutoMask {
    /// Initializes a new credit card mask.
    public init() {}

    /// Applies formatting to convert raw input into a formatted credit card number.
    ///
    /// - Parameter text: The raw text input to format
    /// - Returns: A formatted credit card number with spaces between groups of digits
    ///
    /// This method:
    /// - Extracts only the numeric characters from input
    /// - Groups digits with spaces after every 4 digits
    /// - Limits the total number of digits to 19 (most cards are 16 digits)
    ///
    /// Example: "4111222233334444" becomes "4111 2222 3333 4444"
    public func apply(to text: String) -> String {
        let digits = text.filter(\.isNumber)

        if digits.isEmpty {
            return ""
        }

        var result = ""
        var count = 0

        for digit in digits.prefix(19) { // Most credit cards are 16 digits, but allow for some variance
            if count > 0, count % 4 == 0 {
                result.append(" ")
            }
            result.append(digit)
            count += 1
        }

        return result
    }

    /// Determines if a character is allowed to be entered in a credit card field.
    ///
    /// - Parameter character: The character to check
    /// - Returns: `true` if the character is a digit, `false` otherwise
    ///
    /// This method ensures that only numeric characters can be entered,
    /// filtering out letters, symbols, and other non-digit characters.
    public func isAllowed(character: Character) -> Bool {
        character.isNumber
    }
}

/// Extension providing a convenient static accessor for the credit card mask.
public extension AutoMask where Self == CreditCardMask {
    /// Creates a standard credit card number mask in format XXXX XXXX XXXX XXXX.
    ///
    /// This static accessor makes it easy to add credit card masking to form fields:
    ///
    /// ```swift
    /// // Usage with autoMask parameter
    /// FormFormattedTextField(model.cardNumber, autoMask: .creditCard)
    ///
    /// // Or when creating the field model
    /// FormFieldViewModel(
    ///     type: String.self,
    ///     title: "Card Number",
    ///     mask: .creditCard
    /// )
    /// ```
    static var creditCard: CreditCardMask { CreditCardMask() }
}
