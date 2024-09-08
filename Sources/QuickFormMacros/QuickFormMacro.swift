// QuickFormMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// QuickFormMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

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

        // Determine the visibility of the class
        let classVisibility = classDecl.modifiers.first { $0.name.text == "public" || $0.name.text == "internal" }?.name.text ?? "internal"

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

        let initializer = """
        \(classVisibility) init(model: \(modelType)) {
            self._model = model
            update()
            \(propertyEditors.map { identifier, keyPath in
                "track(keyPath: \(keyPath), editor: \(identifier))"
            }.joined(separator: "\n"))
        }
        """

        let trackMethod = """
        func track<Property>(keyPath: WritableKeyPath<\(modelType), Property>, editor: any ValueEditor<Property>) {
           observe { [weak self] in
               self?.model[keyPath: keyPath] = editor.value
            }
        }
        """

        let observationRegistrar = """
        private let _$observationRegistrar = Observation.ObservationRegistrar()
        """

        let accessMethod = """
        internal nonisolated func access<Member>(
            keyPath: KeyPath<\(classDecl.name), Member>
        ) {
            _$observationRegistrar.access(self, keyPath: keyPath)
        }
        """

        let withMutationMethod = """
        internal nonisolated func withMutation<Member, MutationResult>(
            keyPath: KeyPath<\(classDecl.name), Member>,
            _ mutation: () throws -> MutationResult
        ) rethrows -> MutationResult {
            try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
        }
        """

        return [
            DeclSyntax(stringLiteral: modelVar),
            DeclSyntax(stringLiteral: updateMethod),
            DeclSyntax(stringLiteral: initializer),
            DeclSyntax(stringLiteral: trackMethod),
            DeclSyntax(stringLiteral: observationRegistrar),
            DeclSyntax(stringLiteral: accessMethod),
            DeclSyntax(stringLiteral: withMutationMethod)
        ]
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
