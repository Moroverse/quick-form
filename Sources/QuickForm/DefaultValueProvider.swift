// DefaultValueProvider.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-04 19:24 GMT.

import Foundation

public protocol DefaultValueProvider {
    static var defaultValue: Self { get }
}

// Extend common types
extension String: DefaultValueProvider {
    public static var defaultValue: String { "" }
}

extension Int: DefaultValueProvider {
    public static var defaultValue: Int { 0 }
}

extension Double: DefaultValueProvider {
    public static var defaultValue: Double { 0 }
}

extension Date: DefaultValueProvider {
    public static var defaultValue: Date { Date() }
}

extension Optional: DefaultValueProvider where Wrapped: DefaultValueProvider {
    public static var defaultValue: Optional<Wrapped> { nil }
}

extension Decimal: DefaultValueProvider {
    public static var defaultValue: Decimal { 0 }
}

extension Bool: DefaultValueProvider {
    public static var defaultValue: Bool { false }
}
