// OptionalFormat.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

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
///         value: nil as Double?,
///         format: OptionalFormat(format: .currency(code: "USD")),
///         title: "Salary:",
///         placeholder: "Enter salary (optional)"
///     )
/// }
/// ```
public struct OptionalFormat<Value, F>: ParseableFormatStyle
    where F: ParseableFormatStyle, F.FormatInput == Value, F.FormatOutput == String {
    private let format: F
    /// The parse strategy for the optional format.
    public var parseStrategy: OptionalFormatStrategy<Value, F.Strategy> {
        OptionalFormatStrategy(strategy: format.parseStrategy)
    }

    /// Formats the given optional value.
    ///
    /// - Parameter value: The optional value to format.
    /// - Returns: A formatted string representation of the value, or an empty string if the value is `nil`.
    public func format(_ value: Value?) -> String {
        if let value {
            format.format(value)
        } else {
            ""
        }
    }

    /// Initializes a new `OptionalFormat` with the given format style.
    ///
    /// - Parameter format: The format style to wrap.
    public init(format: F) {
        self.format = format
    }
}

/// A parse strategy for optional values that wraps another parse strategy.
public struct OptionalFormatStrategy<Value, S>: ParseStrategy
    where S: ParseStrategy, S.ParseInput == String, S.ParseOutput == Value {
    private let strategy: S
    /// Parses the given string into an optional value.
    ///
    /// - Parameter value: The string to parse.
    /// - Returns: The parsed value, or `nil` if the string is empty.
    /// - Throws: An error if parsing fails for a non-empty string.
    public func parse(_ value: String) throws -> Value? {
        if value.isEmpty {
            nil
        } else {
            try strategy.parse(value)
        }
    }

    init(strategy: S) {
        self.strategy = strategy
    }
}

public struct PlainStringStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> String {
        value
    }
}

public struct PlainStringFormat: ParseableFormatStyle {
    public var parseStrategy: PlainStringStrategy {
        PlainStringStrategy()
    }

    public func format(_ value: String) -> String {
        value
    }

    public init() {}
}
