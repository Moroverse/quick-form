// OptionalProtocol.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 06:14 GMT.

protocol OptionalProtocol {
    var wrappedValue: Any? { get }
}

extension Optional: OptionalProtocol {
    var wrappedValue: Any? {
        map { $0 }
    }
}
