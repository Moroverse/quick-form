// PlainStringFormat.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-04 07:30 GMT.

import Foundation

/// A format style that doesn't modify strings when formatting and parsing.
///
/// `PlainStringFormat` is a simple identity format style that conforms to `ParseableFormatStyle`
/// and keeps strings unchanged during both formatting and parsing operations. This is useful when
/// you need to satisfy a type requirement for a format style but want the string values to remain
/// unmodified.
///
/// ## Features
/// - Preserves the original string during formatting
/// - Returns the original input during parsing
/// - Useful as a no-op format style in generic contexts
///
/// ## Example
///
/// ```swift
/// let format = PlainStringFormat()
///
/// // Formatting
/// let formatted = format.format("Hello World") // "Hello World"
///
/// // Parsing
/// let parsed = try? format.parseStrategy.parse("Hello World") // "Hello World"
///
/// // Usage in a form field
/// @QuickForm(UserForm.self)
/// class UserFormModel: Validatable {
///     @PropertyEditor(keyPath: \UserForm.notes)
///     var notes = FormattedFieldViewModel(
///         type: String.self,
///         format: PlainStringFormat(),
///         title: "Notes:",
///         placeholder: "Enter any additional notes"
///     )
/// }
/// ```
///
/// ## Common Use Cases
///
/// ### Default String Handling
/// ```swift
/// @PropertyEditor(keyPath: \ContactForm.fullName)
/// var fullName = FormattedFieldViewModel(
///     type: String.self,
///     format: PlainStringFormat(),
///     title: "Full Name:",
///     placeholder: "Enter your full name"
/// )
/// ```
///
/// ### When No Transformation Is Needed
/// ```swift
/// @PropertyEditor(keyPath: \FeedbackForm.comments)
/// var comments = FormattedFieldViewModel(
///     type: String.self,
///     format: PlainStringFormat(),
///     title: "Comments:",
///     placeholder: "Enter your comments here"
/// )
/// ```
///
/// - SeeAlso: `FormattedFieldViewModel`, `ParseableFormatStyle`, `OptionalFormat`
public struct PlainStringFormat: ParseableFormatStyle {
    /// The parse strategy for plain strings.
    ///
    /// This property provides access to a `PlainStringStrategy` instance that returns
    /// the original string during parsing operations.
    ///
    /// - Returns: A strategy for parsing strings without modification.
    public var parseStrategy: PlainStringStrategy {
        PlainStringStrategy()
    }

    /// Returns the string value without any formatting changes.
    ///
    /// - Parameter value: The string value to format.
    /// - Returns: The original string, unchanged.
    public func format(_ value: String) -> String {
        value
    }

    /// Initializes a new `PlainStringFormat`.
    ///
    /// This initializer creates a new format style that preserves strings
    /// during formatting and parsing operations.
    public init() {}
}

/// A parse strategy for plain strings that returns them unchanged.
///
/// `PlainStringStrategy` is a simple identity parse strategy that returns the
/// original string during parsing operations without any modifications.
///
/// - SeeAlso: `PlainStringFormat`, `ParseStrategy`
public struct PlainStringStrategy: ParseStrategy {
    /// Parses a string by simply returning it unchanged.
    ///
    /// - Parameter value: The string to parse.
    /// - Returns: The original string, unchanged.
    /// - Throws: This method never throws an error.
    public func parse(_ value: String) throws -> String {
        value
    }
}
