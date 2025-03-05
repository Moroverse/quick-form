// PlainStringFormat.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-04 08:27 GMT.

import Foundation

public struct PlainStringFormat: ParseableFormatStyle {
    public var parseStrategy: PlainStringStrategy {
        PlainStringStrategy()
    }

    public func format(_ value: String) -> String {
        value
    }

    public init() {}
}

public struct PlainStringStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> String {
        value
    }
}
