//
//  MTe.swift
//  quick-form
//
//  Created by Daniel Moro on 2.3.25..
//

import MacroTesting
import SwiftSyntaxMacrosTestSupport
import Testing
#if canImport(QuickFormMacros)
    import QuickFormMacros
#endif

let canTestMacros: Bool = {
    #if canImport(QuickFormMacros)
        return true
    #else
        return false
    #endif
}()

#if canImport(QuickFormMacros)
    struct QuickFormMacroTests {
        @Test(
            .enabled(if: canTestMacros),
            .macros(
                record: .missing,
                macros: ["QuickForm": QuickFormMacro.self]
            )
        )
        func testQuickFormMacro() {
            assertMacro {
                #"""
                @QuickForm(Person.self)
                class PersonFormController {
                }
                """#
            } expansion: {
                #"""
                class PersonFormController {

                    internal var value: Person {
                        get {
                            access(keyPath: \.value)
                            return _value
                        }
                        set {
                            withMutation(keyPath: \.value) {
                                _value = newValue
                            }
                        }
                    }
                    private var _value: Person

                    internal func update() {

                    }

                    internal init(value: Person) {
                        self._value = value
                        update()


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
                """#
            }
        }

        @Test(
            .enabled(if: canTestMacros),
            .macros(
                record: .missing,
                macros: ["PropertyEditor": PropertyEditorMacro.self]
            )
        )
        func testPropertyEditorMacro() {
            assertMacro {
                #"""
                class PersonFormController {
                    @PropertyEditor(keyPath: \Person.name)
                    var nameField = FormFieldViewModel(value: "", title: "Name")
                }
                """#
            } expansion: {
                #"""
                class PersonFormController {
                    var nameField {
                        @storageRestrictions(initializes: _nameField)
                        init(initialValue) {
                            _nameField = initialValue
                        }
                        get {
                            access(keyPath: \.nameField)
                            return _nameField
                        }
                        set {
                            withMutation(keyPath: \.nameField) {
                                _nameField = newValue
                            }
                        }
                        _modify {
                            access(keyPath: \.nameField)
                            _$observationRegistrar.willSet(self, keyPath: \.nameField)
                            defer {
                                _$observationRegistrar.didSet(self, keyPath: \.nameField)
                            }
                            yield &_nameField
                        }
                    }

                    private var _nameField = FormFieldViewModel(value: "", title: "Name")
                }
                """#
            }
        }

        @Test(
            .enabled(if: canTestMacros),
            .macros(
                record: .missing,
                macros: ["QuickForm": QuickFormMacro.self, "PropertyEditor": PropertyEditorMacro.self]
            )
        )
        func testQuickFormMacroAndPropertyEditorMacro() {
            assertMacro {
                #"""
                @QuickForm(Person.self)
                class PersonFormController {
                    @PropertyEditor(keyPath: \Person.name)
                    var nameField = FormFieldViewModel(value: "", title: "Name")
                }
                """#
            } expansion: {
                #"""
                class PersonFormController {
                    var nameField {
                        @storageRestrictions(initializes: _nameField)
                        init(initialValue) {
                            _nameField = initialValue
                        }
                        get {
                            access(keyPath: \.nameField)
                            return _nameField
                        }
                        set {
                            withMutation(keyPath: \.nameField) {
                                _nameField = newValue
                            }
                        }
                        _modify {
                            access(keyPath: \.nameField)
                            _$observationRegistrar.willSet(self, keyPath: \.nameField)
                            defer {
                                _$observationRegistrar.didSet(self, keyPath: \.nameField)
                            }
                            yield &_nameField
                        }
                    }

                    private var _nameField = FormFieldViewModel(value: "", title: "Name")

                    internal var value: Person {
                        get {
                            access(keyPath: \.value)
                            return _value
                        }
                        set {
                            withMutation(keyPath: \.value) {
                                _value = newValue
                            }
                        }
                    }
                    private var _value: Person

                    internal func update() {
                        nameField.value = _value[keyPath: \Person.name]
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
                                    self.value[keyPath: \Person.name] = nameField.value

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
                """#
            }
        }
    }
#endif
