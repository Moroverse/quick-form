// CompoundValue.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2026-03-05 GMT.

import Foundation

/// A protocol for types that represent a numeric value paired with a unit.
///
/// `CompoundValue` abstracts the pattern of a numeric value associated with a selectable unit,
/// enabling generic form fields that work with any value+unit pair — not just Foundation's
/// `Measurement<Unit>`.
///
/// The ``ValueType`` associated type defaults to `Double`, so existing conformers require no
/// changes. To use a different numeric type, specify it explicitly:
///
/// ```swift
/// struct Quantity: CompoundValue {
///     typealias ValueType = Int
///     var value: Int
///     var unit: MyUnit
///     // ...
/// }
/// ```
///
/// ## Conformance Requirements
///
/// - ``value``: The numeric component (get-only; mutations go through ``init(value:unit:)``).
/// - ``unit``: The unit component (get-only).
/// - ``allUnits``: All units available for selection in the picker.
/// - ``displayString(for:)``: Human-readable label for a unit.
/// - ``init(value:unit:)``: Memberwise initializer used to create mutated copies.
///
/// ## Example
///
/// ```swift
/// struct DoseAmount: CompoundValue {
///     var value: Double
///     var unit: SnomedConcept
///
///     static var allUnits: [SnomedConcept] { [.mg, .mcg, .ml] }
///     static func displayString(for unit: SnomedConcept) -> String { unit.term }
///     init(value: Double, unit: SnomedConcept) { self.value = value; self.unit = unit }
/// }
/// ```
///
/// - SeeAlso: ``FormCompoundField``, ``FormOptionalCompoundField``
public protocol CompoundValue {
    associatedtype ValueType: CompoundNumeric = Double
    associatedtype UnitType: Identifiable & Hashable
    var value: ValueType { get set }
    var unit: UnitType { get }
    static var allUnits: [UnitType] { get }
    static func displayString(for unit: UnitType) -> String
    init(value: ValueType, unit: UnitType)
}

extension CompoundValue where UnitType: CustomStringConvertible {
    public static func displayString(for unit: UnitType) -> String {
        unit.description
    }
}

// MARK: - Measurement Retroactive Conformance

extension Measurement: CompoundValue where UnitType: AllValues, UnitType.Unit == UnitType {
    public static var allUnits: [UnitType] { UnitType.allCases }
    public static func displayString(for unit: UnitType) -> String { unit.symbol }
}
