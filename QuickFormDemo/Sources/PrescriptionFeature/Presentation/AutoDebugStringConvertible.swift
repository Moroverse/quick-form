// AutoDebugStringConvertible.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-29 15:46 GMT.

protocol AutoDebugStringConvertible: CustomDebugStringConvertible {}

extension AutoDebugStringConvertible {
    var debugDescription: String {
        let mirror = Mirror(reflecting: self)
        let properties = mirror.children.map { child in
            if let label = child.label {
                return "\(label): \(String(reflecting: child.value))"
            }
            return String(reflecting: child.value)
        }
        return "\(type(of: self))(\(properties.joined(separator: ", ")))"
    }
}
