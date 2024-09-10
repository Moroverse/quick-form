// QuickFormMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// QuickFormMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

public struct QuickFormMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.invalidDeclaration
        }

        guard case let .argumentList(arguments) = node.arguments,
              let firstArg = arguments.first?.expression.as(MemberAccessExprSyntax.self),
              let modelType = firstArg.base?.as(DeclReferenceExprSyntax.self)?.baseName.text else {
            throw MacroError.invalidArguments
        }

        let propertyEditors = classDecl.memberBlock.members.compactMap { member -> (String, String)? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let propertyEditorAttr = varDecl.attributes.first(where: { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "PropertyEditor" })
            else { return nil }

            guard case let .argumentList(arguments) = propertyEditorAttr.as(AttributeSyntax.self)?.arguments,
                  let keyPathArg = arguments.first?.expression.as(KeyPathExprSyntax.self),
                  let keyPath = keyPathArg.components.last?.component.as(KeyPathPropertyComponentSyntax.self)?.declName.baseName.text
            else { return nil }

            return (identifier, "\\\(modelType).\(keyPath)")
        }

        let conformsToValidatable = classDecl.inheritanceClause?.inheritedTypes.contains { type in
            type.type.as(IdentifierTypeSyntax.self)?.name.text == "Validatable"
        } ?? false

        let conformsToCustomValidatable = classDecl.inheritanceClause?.inheritedTypes.contains { type in
            type.type.as(IdentifierTypeSyntax.self)?.name.text == "CustomValidatable"
        } ?? false

        let classVisibility = classDecl.modifiers.first { $0.name.text == "public" || $0.name.text == "internal" }?.name.text ?? "internal"

        var declarations: [DeclSyntax] = []

        // Add model property
        let modelVar = """
        \(classVisibility) var model: \(modelType) {
            get {
                access(keyPath: \\.model)
                return _model
            }
            set {
                withMutation(keyPath: \\.model) {
                    _model = newValue
                }
            }
        }
        private var _model: \(modelType)
        """
        declarations.append(DeclSyntax(stringLiteral: modelVar))

        // Add update method
        let updateMethodContent = propertyEditors.map { identifier, keyPath in
            """
            \(identifier).value = _model[keyPath: \(keyPath)]
            """
        }.joined(separator: "\n")

        let updateMethod = """
        \(classVisibility) func update() {
            \(updateMethodContent)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: updateMethod))

        // Add initializer
        let initializer = """
        \(classVisibility) init(model: \(modelType)) {
            self._model = model
            update()
            \(propertyEditors.map { identifier, keyPath in
                "track(keyPath: \(keyPath), editor: \(identifier))"
            }.joined(separator: "\n"))
        }
        """
        declarations.append(DeclSyntax(stringLiteral: initializer))

        // Add observation registrar
        let observationRegistrar = """
        private let _$observationRegistrar = Observation.ObservationRegistrar()
        """
        declarations.append(DeclSyntax(stringLiteral: observationRegistrar))

        // Add access method
        let accessMethod = """
        internal nonisolated func access<Member>(
            keyPath: KeyPath<\(classDecl.name), Member>
        ) {
            _$observationRegistrar.access(self, keyPath: keyPath)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: accessMethod))

        // Add withMutation method
        let withMutationMethod = """
        internal nonisolated func withMutation<Member, MutationResult>(
            keyPath: KeyPath<\(classDecl.name), Member>,
            _ mutation: () throws -> MutationResult
        ) rethrows -> MutationResult {
            try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: withMutationMethod))

        if conformsToValidatable || conformsToCustomValidatable {
            // Add private validationResult property
            let validationResultProperty = """
            private var _validationResult: ValidationResult = .success {
                didSet {
                    if oldValue != _validationResult {
                        _$observationRegistrar.willSet(self, keyPath: \\.validationResult)
                        _$observationRegistrar.didSet(self, keyPath: \\.validationResult)
                    }
                }
            }
            """
            declarations.append(DeclSyntax(stringLiteral: validationResultProperty))

            // Add public computed validationResult property
            let computedValidationResultProperty = """
            \(classVisibility) var validationResult: ValidationResult {
                get {
                    access(keyPath: \\.validationResult)
                    return _validationResult
                }
            }
            """
            declarations.append(DeclSyntax(stringLiteral: computedValidationResultProperty))

            // Add validate method
            let validateMethod = """
            \(classVisibility) func validate() -> ValidationResult {
                let results = [\(propertyEditors.map { identifier, _ in
                    "\(identifier).validate()"
                }.joined(separator: ", "))]

                for result in results {
                    if case .failure(let error) = result {
                        return .failure(error)
                    }
                }

                if let customValidation = (self as? CustomValidatable)?.customValidation {
                    return customValidation(.success)
                }

                return .success
            }
            """
            declarations.append(DeclSyntax(stringLiteral: validateMethod))

            // Modify track method to update _validationResult
            let trackMethod = """
            func track<Property>(keyPath: WritableKeyPath<\(modelType), Property>, editor: any ValueEditor<Property>) {
               observe { [weak self] in
                   self?.model[keyPath: keyPath] = editor.value
                   self?._validationResult = self?.validate() ?? .success
                }
            }
            """
            declarations.append(DeclSyntax(stringLiteral: trackMethod))
        }

        if conformsToCustomValidatable {
            let customValidationProperty = """
            public var customValidation: ((ValidationResult) -> ValidationResult)?
            """
            declarations.append(DeclSyntax(stringLiteral: customValidationProperty))
        }

        return declarations
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let observableConformance = try ExtensionDeclSyntax("extension \(type): Observable { }")
        return [observableConformance]
    }
}

enum MacroError: Error {
    case invalidDeclaration
    case invalidArguments
}
