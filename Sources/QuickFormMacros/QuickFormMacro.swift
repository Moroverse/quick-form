// QuickFormMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct QuickFormMacro: MemberMacro {
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

        let modelVar = "public var model: \(modelType)"

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

        let initializerContent = propertyEditors.map { identifier, keyPath in
            """
            \(identifier).value = model[keyPath: \(keyPath)]
            track(keyPath: \(keyPath), editor: \(identifier))
            """
        }.joined(separator: "\n        ")

        let initializer = """
        public init(model: \(modelType)) {
            self.model = model

            \(initializerContent)
        }
        """

        let trackMethod = """
        func track<Property>(keyPath: WritableKeyPath<\(modelType), Property>, editor: any ValueEditor<Property>) {
           observe { [weak self] in
               self?.model[keyPath: keyPath] = editor.value
            }
        }
        """

        return [
            DeclSyntax(stringLiteral: modelVar),
            DeclSyntax(stringLiteral: initializer),
            DeclSyntax(stringLiteral: trackMethod)
        ]
    }
}

enum MacroError: Error {
    case invalidDeclaration
    case invalidArguments
}
