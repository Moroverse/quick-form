// CompoundNumeric.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2026-03-05 GMT.

import Foundation

/// A protocol that bridges numeric types to their `ParseableFormatStyle`,
/// enabling ``CompoundValue`` to work with any numeric type in SwiftUI text fields.
///
/// Conform custom numeric types to this protocol to use them with
/// ``FormCompoundField`` and ``FormOptionalCompoundField``.
///
/// Built-in conformances are provided for `Double`, `Float`, `Int`, and `Decimal`.
public protocol CompoundNumeric: Hashable, Sendable {
    associatedtype NumberFormatStyle: ParseableFormatStyle
        where NumberFormatStyle.FormatOutput == String,
              NumberFormatStyle.FormatInput == Self
    static var compoundNumberFormat: NumberFormatStyle { get }
}

extension Double: CompoundNumeric {
    public static var compoundNumberFormat: FloatingPointFormatStyle<Double> { .number }
}

extension Float: CompoundNumeric {
    public static var compoundNumberFormat: FloatingPointFormatStyle<Float> { .number }
}

extension Int: CompoundNumeric {
    public static var compoundNumberFormat: IntegerFormatStyle<Int> { .number }
}

extension Decimal: CompoundNumeric {
    public static var compoundNumberFormat: Decimal.FormatStyle { .number }
}
