// USPhoneNumberFormatStyle.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

import Foundation

/// A format style for US phone numbers.
///
/// `USPhoneNumberFormatStyle` provides formatting and parsing capabilities for US phone numbers,
/// allowing you to convert between raw digit strings and formatted phone numbers following US
/// conventions.
///
/// ## Features
/// - Formats 10-digit phone numbers using standard US patterns
/// - Supports multiple format types (standard dashes or parentheses)
/// - Strips non-numeric characters during parsing
/// - Validates that phone numbers contain exactly 10 digits
///
/// ## Example
///
/// ```swift
/// let formatter = USPhoneNumberFormatStyle(.parentheses)
///
/// // Formatting
/// let formatted = formatter.format("1234567890") // "(123) 456-7890"
///
/// // Parsing
/// let parsed = try? formatter.parseStrategy.parse("(123) 456-7890") // "1234567890"
///
/// // Usage in a form field (actual usage from codebase)
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
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
/// - SeeAlso: ``USPhoneNumberParseStrategy``, `ParseableFormatStyle`
public struct USPhoneNumberFormatStyle: Codable, ParseableFormatStyle {
    /// The format type to use when formatting phone numbers.
    ///
    /// - `standard`: Uses dashes between number groups (123-456-7890)
    /// - `parentheses`: Uses parentheses and spaces (123) 456-7890
    public enum FormatType: Codable {
        case standard
        case parentheses
    }

    public typealias Strategy = USPhoneNumberParseStrategy

    private let formatType: FormatType

    /// The parse strategy for US phone numbers.
    ///
    /// This property returns a ``USPhoneNumberParseStrategy`` that can be used to
    /// parse formatted phone number strings back into raw digit strings.
    ///
    /// - Returns: A strategy for parsing US phone numbers.
    public var parseStrategy: USPhoneNumberParseStrategy {
        USPhoneNumberParseStrategy()
    }

    /// Initializes a new format style with the specified format type.
    ///
    /// - Parameter formatType: The format type to use, defaults to `.standard`.
    public init(_ formatType: FormatType = .standard) {
        self.formatType = formatType
    }

    /// Formats a string as a US phone number.
    ///
    /// This method takes a string of digits and formats it according to US phone number
    /// conventions. If the input does not contain exactly 10 digits after stripping
    /// non-numeric characters, the original string is returned unchanged.
    ///
    /// - Parameter value: The string to format, typically a sequence of digits.
    /// - Returns: A formatted US phone number string, or the original string if invalid.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let standard = USPhoneNumberFormatStyle(.standard)
    /// standard.format("1234567890") // "123-456-7890"
    ///
    /// let parentheses = USPhoneNumberFormatStyle(.parentheses)
    /// parentheses.format("1234567890") // "(123) 456-7890"
    /// ```
    public func format(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard cleaned.count == 10 else { return value }

        switch formatType {
        case .standard:
            return cleaned.replacingOccurrences(
                of: "(\\d{3})(\\d{3})(\\d+)",
                with: "$1-$2-$3",
                options: .regularExpression
            )

        case .parentheses:
            return cleaned.replacingOccurrences(
                of: "(\\d{3})(\\d{3})(\\d+)",
                with: "($1) $2-$3",
                options: .regularExpression
            )
        }
    }
}

/// A parse strategy for US phone numbers.
///
/// ``USPhoneNumberParseStrategy`` handles the conversion of formatted US phone number
/// strings back into raw digit strings. It strips all non-numeric characters and
/// validates that the result contains exactly 10 digits.
///
/// - SeeAlso: ``USPhoneNumberFormatStyle``, `ParseStrategy`
public struct USPhoneNumberParseStrategy: ParseStrategy {
    /// Parses a formatted phone number string into a raw digit string.
    ///
    /// - Parameter value: The formatted phone number string to parse.
    /// - Returns: A string containing exactly 10 digits.
    /// - Throws: ``ParseError/invalidPhoneNumber`` if the result doesn't contain exactly 10 digits.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let strategy = USPhoneNumberParseStrategy()
    /// try strategy.parse("123-456-7890") // "1234567890"
    /// try strategy.parse("(123) 456-7890") // "1234567890"
    /// try strategy.parse("123") // Throws ParseError.invalidPhoneNumber
    /// ```
    public func parse(_ value: String) throws -> String {
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard cleaned.count == 10 else {
            throw ParseError.invalidPhoneNumber
        }
        return cleaned
    }
}

/// Errors that can occur during phone number parsing.
public enum ParseError: Error {
    /// Indicates that the input string doesn't represent a valid US phone number.
    case invalidPhoneNumber
}

/// Extension providing convenient static access to US phone number format styles.
public extension FormatStyle where Self == USPhoneNumberFormatStyle {
    /// A format style for US phone numbers using the standard format (123-456-7890).
    static var usPhoneNumber: USPhoneNumberFormatStyle { USPhoneNumberFormatStyle() }

    /// Creates a format style for US phone numbers with the specified format type.
    ///
    /// - Parameter formatType: The format type to use.
    /// - Returns: A new ``USPhoneNumberFormatStyle`` configured with the specified format type.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a FormattedFieldViewModel
    /// FormattedFieldViewModel(
    ///     type: String.self,
    ///     format: .usPhoneNumber(.parentheses),
    ///     title: "Phone Number:",
    ///     placeholder: "(555) 555-5555",
    ///     validation: .of(.usPhoneNumber)
    /// )
    /// ```
    static func usPhoneNumber(_ formatType: USPhoneNumberFormatStyle.FormatType) -> USPhoneNumberFormatStyle {
        USPhoneNumberFormatStyle(formatType)
    }
}
