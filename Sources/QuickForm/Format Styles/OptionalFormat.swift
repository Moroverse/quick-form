// OptionalFormat.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

import Foundation

/// A format style for optional values that wraps another format style.
///
/// `OptionalFormat` is a struct that conforms to `ParseableFormatStyle` and allows you to apply
/// a format style to an optional value. It handles both the formatting of non-nil values using
/// the wrapped format style and the parsing of empty strings as `nil`.
///
/// This is particularly useful in form fields where a value might be optional, allowing for
/// empty input while still applying formatting when a value is present.
///
/// ## Features
/// - Wraps any `ParseableFormatStyle` to work with optional values
/// - Formats `nil` as an empty string
/// - Parses empty strings as `nil`
/// - Applies the wrapped format style to non-nil values
///
/// ## Example
///
/// ```swift
/// let currencyFormat = OptionalFormat(format: .currency(code: "USD"))
///
/// // Formatting
/// let formattedValue = currencyFormat.format(5000) // "$5,000.00"
/// let formattedNil = currencyFormat.format(nil) // ""
///
/// // Parsing
/// let parsedValue = try? currencyFormat.parseStrategy.parse("$5,000.00") // Optional(5000.0)
/// let parsedEmpty = try? currencyFormat.parseStrategy.parse("") // nil
///
/// // Usage in a form field
/// @QuickForm(EmployeeForm.self)
/// class EmployeeFormModel: Validatable {
///     @PropertyEditor(keyPath: \EmployeeForm.salary)
///     var salary = FormattedFieldViewModel(
///         type: Double?.self,
///         format: OptionalFormat(format: .currency(code: "USD")),
///         title: "Salary:",
///         placeholder: "Enter salary (optional)"
///     )
/// }
/// ```
///
/// ## Common Use Cases
///
/// ### Optional Date Fields
/// ```swift
/// @PropertyEditor(keyPath: \PersonInfo.birthDate)
/// var birthDate = FormattedFieldViewModel(
///     type: Date?.self,
///     format: OptionalFormat(format: .date.year().month().day()),
///     title: "Birth Date:",
///     placeholder: "Enter birth date (optional)"
/// )
/// ```
///
/// ### Optional Numeric Values
/// ```swift
/// @PropertyEditor(keyPath: \Product.weight)
/// var weight = FormattedFieldViewModel(
///     type: Double?.self,
///     format: OptionalFormat(format: .number.precision(.fractionLength(2))),
///     title: "Weight (kg):",
///     placeholder: "Enter weight (optional)"
/// )
/// ```
///
/// - SeeAlso: `FormattedFieldViewModel`, `ParseableFormatStyle`
public struct OptionalFormat<Value, F>: ParseableFormatStyle
    where F: ParseableFormatStyle, F.FormatInput == Value, F.FormatOutput == String {
    private let format: F

    /// The parse strategy for the optional format.
    ///
    /// This property returns an `OptionalFormatStrategy` that wraps the underlying format's
    /// parse strategy. When used, it will handle empty strings as `nil` values and delegate
    /// non-empty strings to the wrapped strategy.
    ///
    /// - SeeAlso: `OptionalFormatStrategy`
    public var parseStrategy: OptionalFormatStrategy<Value, F.Strategy> {
        OptionalFormatStrategy(strategy: format.parseStrategy)
    }

    /// Formats the given optional value.
    ///
    /// - Parameter value: The optional value to format.
    /// - Returns: A formatted string representation of the value, or an empty string if the value is `nil`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let dateFormat = OptionalFormat(format: .date)
    /// dateFormat.format(Date()) // "9/30/2024"
    /// dateFormat.format(nil) // ""
    /// ```
    public func format(_ value: Value?) -> String {
        if let value {
            format.format(value)
        } else {
            ""
        }
    }

    /// Initializes a new `OptionalFormat` with the given format style.
    ///
    /// - Parameter format: The format style to wrap. This will be used to format non-nil values
    ///                     and parse non-empty strings.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Creating an optional currency format
    /// let currencyFormat = OptionalFormat(format: .currency(code: "USD"))
    ///
    /// // Creating an optional number format with precision
    /// let numberFormat = OptionalFormat(
    ///     format: .number.precision(.fractionLength(2))
    /// )
    /// ```
    public init(format: F) {
        self.format = format
    }
}

/// A parse strategy for optional values that wraps another parse strategy.
///
/// This strategy allows parsing strings into optional values by:
/// - Returning `nil` for empty strings
/// - Using the wrapped strategy to parse non-empty strings
/// - Preserving error handling from the original strategy
///
/// `OptionalFormatStrategy` is primarily used internally by `OptionalFormat` and is exposed
/// through its `parseStrategy` property.
///
/// ## Error Handling
///
/// If the input string is non-empty but cannot be parsed by the wrapped strategy,
/// the original error from the wrapped strategy is propagated:
///
/// ```swift
/// let dateFormat = OptionalFormat(format: .date)
///
/// try dateFormat.parseStrategy.parse("") // Returns nil
/// try dateFormat.parseStrategy.parse("9/30/2024") // Returns Date
/// try dateFormat.parseStrategy.parse("invalid") // Throws DateFormatStyle.FormatError
/// ```
///
/// - SeeAlso: `OptionalFormat`, `ParseStrategy`
public struct OptionalFormatStrategy<Value, S>: ParseStrategy
    where S: ParseStrategy, S.ParseInput == String, S.ParseOutput == Value {
    private let strategy: S

    /// Parses the given string into an optional value.
    ///
    /// - Parameter value: The string to parse.
    /// - Returns: The parsed value, or `nil` if the string is empty.
    /// - Throws: An error if parsing fails for a non-empty string.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let numberFormat = OptionalFormat(format: .number)
    /// let strategy = numberFormat.parseStrategy
    ///
    /// try strategy.parse("") // nil
    /// try strategy.parse("123") // Optional(123)
    /// try strategy.parse("abc") // Throws FormatError
    /// ```
    public func parse(_ value: String) throws -> Value? {
        if value.isEmpty {
            nil
        } else {
            try strategy.parse(value)
        }
    }

    /// Initializes a new strategy with the provided parse strategy.
    ///
    /// - Parameter strategy: The underlying strategy used to parse non-empty strings.
    ///
    /// This initializer is primarily used internally by `OptionalFormat`.
    init(strategy: S) {
        self.strategy = strategy
    }
}
