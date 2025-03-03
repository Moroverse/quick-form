// FormFieldViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 05:39 GMT.

import QuickForm
import Testing

@Suite("FormFieldViewModelTests")
struct FormFieldViewModelTests {
    @Test("Initializes with correct properties")
    func modelInit() {
        let sut = FormFieldViewModel<String>(
            value: "banana",
            title: "local banana",
            placeholder: "fruit",
            isReadOnly: false
        )

        #expect(sut.value == "banana")
        #expect(sut.title == "local banana")
        #expect(sut.placeholder == "fruit")
        #expect(sut.isReadOnly == false)
    }

    @Test("Calls all registered callbacks when value changes")
    func onValueChange() {
        let sut = FormFieldViewModel<String>(value: "banana")
        var recordChange = 0
        var recordedValue: String?
        sut.onValueChanged { newValue in
            recordChange += 1
            recordedValue = newValue
        }

        var secondRecordChange = 0
        var secondRecordedValue: String?
        sut.onValueChanged { newValue in
            secondRecordChange += 1
            secondRecordedValue = newValue
        }

        #expect(sut.value == "banana")
        sut.value = "apple"
        #expect(recordChange == 1)
        #expect(recordedValue == "apple")
        #expect(secondRecordChange == 1)
        #expect(secondRecordedValue == "apple")
    }

    @Test("Validates model values according to validation rules")
    func validation() {
        let sut = FormFieldViewModel<String>(
            value: "banana",
            validation: .of(.notEmpty)
        )

        #expect(sut.isValid == true)
        sut.value = ""
        #expect(sut.isValid == false)
        sut.value = "apple"
        #expect(sut.isValid == true)
    }
}
