// CompoundValueTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2026-03-05 GMT.

import Foundation
import QuickForm
import Testing

@Suite("CompoundValue generic numeric types")
struct CompoundValueTests {
    // MARK: - Int-based CompoundValue

    struct IntQuantity: CompoundValue, Equatable {
        typealias ValueType = Int

        var value: Int
        var unit: StringUnit

        static var allUnits: [StringUnit] { [StringUnit(id: "pcs"), StringUnit(id: "boxes")] }
        static func displayString(for unit: StringUnit) -> String { unit.id }
        init(value: Int, unit: StringUnit) { self.value = value; self.unit = unit }
    }

    struct StringUnit: Identifiable, Hashable {
        var id: String
    }

    @MainActor
    @Test("Int-based CompoundValue stores and mutates value")
    func intCompoundValue() {
        let pcs = StringUnit(id: "pcs")
        var sut = IntQuantity(value: 5, unit: pcs)

        #expect(sut.value == 5)
        #expect(sut.unit.id == "pcs")

        sut.value = 10
        #expect(sut.value == 10)
    }

    @MainActor
    @Test("Int-based CompoundValue works with FormFieldViewModel")
    func intCompoundFieldViewModel() {
        let pcs = StringUnit(id: "pcs")
        let sut = FormFieldViewModel(
            value: IntQuantity(value: 3, unit: pcs),
            title: "Quantity"
        )

        #expect(sut.value.value == 3)
        sut.value = IntQuantity(value: 7, unit: StringUnit(id: "boxes"))
        #expect(sut.value.value == 7)
        #expect(sut.value.unit.id == "boxes")
    }

    // MARK: - Double-based CompoundValue (backward compatibility)

    struct DoubleAmount: CompoundValue, Equatable {
        var value: Double
        var unit: StringUnit

        static var allUnits: [StringUnit] { [StringUnit(id: "mg"), StringUnit(id: "ml")] }
        static func displayString(for unit: StringUnit) -> String { unit.id }
        init(value: Double, unit: StringUnit) { self.value = value; self.unit = unit }
    }

    @MainActor
    @Test("Double-based CompoundValue infers ValueType = Double without explicit typealias")
    func doubleCompoundValue() {
        let mg = StringUnit(id: "mg")
        let sut = DoubleAmount(value: 1.5, unit: mg)

        #expect(sut.value == 1.5)
        #expect(sut.unit.id == "mg")
    }

    // MARK: - CompoundNumeric format styles

    @MainActor
    @Test("CompoundNumeric format styles produce strings")
    func formatStyles() {
        let doubleStr = Double.compoundNumberFormat.format(3.14)
        #expect(!doubleStr.isEmpty)

        let intStr = Int.compoundNumberFormat.format(42)
        #expect(!intStr.isEmpty)

        let floatStr = Float.compoundNumberFormat.format(2.5)
        #expect(!floatStr.isEmpty)

        let decimalStr = Decimal.compoundNumberFormat.format(99.99)
        #expect(!decimalStr.isEmpty)
    }
}
