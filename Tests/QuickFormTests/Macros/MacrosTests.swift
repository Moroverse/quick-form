// MacrosTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-03 05:18 GMT.

#if canImport(QuickFormMacros)
    import QuickFormMacros
    import MacroTesting
    import SwiftSyntaxMacrosTestSupport
    import Testing
#endif

nonisolated let canTestMacros: Bool = {
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
                ["QuickForm": QuickFormMacro.self],
                record: .missing
            )
        )
        func quickFormMacro() {
            assertMacro {
                #"""
                @QuickForm(Person.self)
                class PersonFormController {
                    @Dependency
                    var loader: Loader

                    var expectedField: String

                    @onInit
                    func onInit() {
                        expectedField = "Hi"
                    }

                    @PostInit()
                    func postInit() {
                        expectedField = "Hi There"
                    }
                }
                """#
            } expansion: {
                #"""
                class PersonFormController {
                    @Dependency
                    var loader: Loader

                    var expectedField: String

                    @onInit
                    func onInit() {
                        expectedField = "Hi"
                    }

                    @PostInit()
                    func postInit() {
                        expectedField = "Hi There"
                    }

                    internal var value: Person {
                        get {
                            access(keyPath: \.value)
                            return _value
                        }
                        set {
                            withMutation(keyPath: \.value) {
                                _value = newValue
                                dispatcher.publish(newValue)
                            }
                        }
                    }
                    private var _value: Person

                    internal func update() {

                    }

                    internal init(value: Person, loader: Loader) {
                        self._value = value
                        dispatcher = Dispatcher()
                        self.loader = loader


                        update()


                        postInit()
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

                    private var dispatcher: Dispatcher

                    @discardableResult
                    internal func onValueChanged(_ change: @escaping (Person) -> Void) -> Subscription {
                        dispatcher.subscribe(handler: change)
                    }
                }

                extension PersonFormController: Observable {
                }

                extension PersonFormController: @MainActor ObservableValueEditor {
                }
                """#
            }
        }

        @Test(
            .enabled(if: canTestMacros),
            .macros(
                ["PropertyEditor": PropertyEditorMacro.self],
                record: .missing
            )
        )
        func propertyEditorMacro() {
            assertMacro {
                #"""
                class PersonFormController {
                    @PropertyEditor(keyPath: \Person.name)
                    var nameField = FormFieldViewModel(value: "", title: "Name")
                    @PropertyEditor(keyPath: \Person.age)
                    var ageField: FormFieldViewModel<Int>
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
                    var ageField: FormFieldViewModel<Int> {
                        @storageRestrictions(initializes: _ageField)
                        init(initialValue) {
                            _ageField = initialValue
                        }
                        get {
                            access(keyPath: \.ageField)
                            return _ageField
                        }
                        set {
                            withMutation(keyPath: \.ageField) {
                                _ageField = newValue
                            }
                        }
                        _modify {
                            access(keyPath: \.ageField)
                            _$observationRegistrar.willSet(self, keyPath: \.ageField)
                            defer {
                                _$observationRegistrar.didSet(self, keyPath: \.ageField)
                            }
                            yield &_ageField
                        }
                    }

                    private var _ageField: FormFieldViewModel<Int>
                }
                """#
            }
        }

        @Test(
            .enabled(if: canTestMacros),
            .macros(
                ["QuickForm": QuickFormMacro.self, "PropertyEditor": PropertyEditorMacro.self],
                record: .missing
            )
        )
        func quickFormMacroAndPropertyEditorMacro() {
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
                                dispatcher.publish(newValue)
                            }
                        }
                    }
                    private var _value: Person

                    internal func update() {
                        nameField.value = _value[keyPath: \Person.name]
                    }

                    internal init(value: Person) {
                        self._value = value
                        dispatcher = Dispatcher()


                        update()

                        trackNamefield()

                    }

                    private func trackNamefield() {
                        withObservationTracking { [weak self] in
                                _ = self?.nameField.value
                            } onChange: { [weak self] in
                                Task { @MainActor [weak self] in
                                    guard let self else { return }
                                    self.value[keyPath: \Person.name] = nameField.value
                                    
                                    self.trackNamefield()
                                }
                            }
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

                    private var dispatcher: Dispatcher

                    @discardableResult
                    internal func onValueChanged(_ change: @escaping (Person) -> Void) -> Subscription {
                        dispatcher.subscribe(handler: change)
                    }
                }

                extension PersonFormController: Observable {
                }

                extension PersonFormController: @MainActor ObservableValueEditor {
                }
                """#
            }
        }

        @Test(
            .enabled(if: canTestMacros),
            .macros(
                ["StateObserved": StateObservedMacro.self],
                record: .missing
            )
        )
        func stateObservedMacro() {
            assertMacro {
                #"""
                class FormModel {
                    @StateObserved
                    var formState  = FormState.idle
                }
                """#
            } expansion: {
                #"""
                class FormModel {
                    var formState  {
                        @storageRestrictions(initializes: _formState)
                        init(initialValue) {
                            _formState = initialValue
                        }
                        get {
                            access(keyPath: \.formState)
                            return _formState
                        }
                        set {
                            withMutation(keyPath: \.formState) {
                                _formState = newValue
                            }
                        }
                        _modify {
                            access(keyPath: \.formState)
                            _$observationRegistrar.willSet(self, keyPath: \.formState)
                            defer {
                                _$observationRegistrar.didSet(self, keyPath: \.formState)
                            }
                            yield &_formState
                        }
                    }

                    private var _formState = FormState.idle
                }
                """#
            }
        }

        @Test(
            .enabled(if: canTestMacros),
            .macros(
                record: .missing,
                macros: ["StateObserved": StateObservedMacro.self]
            )
        )
        func stateObservedMacroWithBooleanType() {
            assertMacro {
                #"""
                class FormModel {
                    @StateObserved
                    var isLoading: Bool = false
                }
                """#
            } expansion: {
                #"""
                class FormModel {
                    var isLoading: Bool {
                        @storageRestrictions(initializes: _isLoading)
                        init(initialValue) {
                            _isLoading = initialValue
                        }
                        get {
                            access(keyPath: \.isLoading)
                            return _isLoading
                        }
                        set {
                            withMutation(keyPath: \.isLoading) {
                                _isLoading = newValue
                            }
                        }
                        _modify {
                            access(keyPath: \.isLoading)
                            _$observationRegistrar.willSet(self, keyPath: \.isLoading)
                            defer {
                                _$observationRegistrar.didSet(self, keyPath: \.isLoading)
                            }
                            yield &_isLoading
                        }
                    }

                    private var _isLoading: Bool  = false
                }
                """#
            }
        }
    }
#endif
