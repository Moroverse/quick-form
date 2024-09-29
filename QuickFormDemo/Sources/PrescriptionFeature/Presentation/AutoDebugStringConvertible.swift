//
//  AutoDebugStringConvertible.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 29.9.24..
//

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

extension Person: AutoDebugStringConvertible {}
extension Medication: AutoDebugStringConvertible {}
extension MedicationComponents: AutoDebugStringConvertible {}
