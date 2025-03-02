//
//  MTe.swift
//  quick-form
//
//  Created by Daniel Moro on 2.3.25..
//

import MacroTesting
import QuickFormMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    .macros(
        record: .missing,
        macros: ["QuickForm": QuickFormMacro.self]
    )
)
struct QuickFormMacroTests {
    @Test
    func testQuickFormMacro() {
        assertMacro(indentationWidth: .spaces(4)) {
            """
            @QuickForm(Person.self)
            class PersonFormController {
                @PropertyEditor(keyPath: \\Person.name)
                var nameField = FormFieldViewModel(value: "", title: "Name")
            }
            """
        } expansion: {
            """
            class PersonFormController {
                 @PropertyEditor(keyPath: \\Person.name)
                 var nameField = FormFieldViewModel(value: "", title: "Name")

                 internal var value: Person {
                     get {
                         access(keyPath: \\.value)
                         return _value
                     }
                     set {
                         withMutation(keyPath: \\.value) {
                             _value = newValue
                         }
                     }
                 }
                 private var _value: Person

                 internal func update() {
                     nameField.value = _value[keyPath: \\Person.name]
                 }

                 internal init(value: Person) {
                     self._value = value
                     update()
                     func trackNamefield() {
                     withObservationTracking { [weak self] in
                             _ = self?.nameField.value
                         } onChange: { [weak self] in
                             Task { @MainActor [weak self] in
                                 guard let self else {
                                     return
                                 }
                                 self.value[keyPath: \\Person.name] = nameField.value

                                 trackNamefield()
                             }
                         }
                     }

                     trackNamefield()


                 }

                 private let _$observationRegistrar = Observation.ObservationRegistrar()

                 internal nonisolated func access<Member>(
                     keyPath: KeyPath<PersonFormController , Member>
                 ) {
                     _$observationRegistrar.access(self, keyPath: keyPath)
                 }

                 internal nonisolated func withMutation<Member, MutationResult>(
                     keyPath: KeyPath<PersonFormController , Member>,
                     _ mutation: () throws -> MutationResult
                 ) rethrows -> MutationResult {
                     try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                 }

                 private var customValidationRules: [any ValidationRule<Person>] = []

                 internal func addCustomValidationRule(_ rule: some ValidationRule<Person>) {
                     customValidationRules.append(rule)
                 }
             }

             extension PersonFormController: Observable {
             }
            """
        }
    }
}
