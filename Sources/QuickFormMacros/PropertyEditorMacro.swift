// PropertyEditorMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PropertyEditorMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw MacroError.invalidDeclaration
        }

        return [
            """
            @storageRestrictions(initializes: _\(raw: identifier))
            init(initialValue) {
                _\(raw: identifier) = initialValue
            }
            """,
            """
            get {
                access(keyPath: \\.\(raw: identifier))
                return _\(raw: identifier)
            }
            """,
            """
            set {
                withMutation(keyPath: \\.\(raw: identifier)) {
                    _\(raw: identifier) = newValue
                }
            }
            """,
            """
            _modify {
                access(keyPath: \\.\(raw: identifier))
                _$observationRegistrar.willSet(self, keyPath: \\.\(raw: identifier))
                defer {
                    _$observationRegistrar.didSet(self, keyPath: \\.\(raw: identifier))
                }
                yield &_\(raw: identifier)
            }
            """
        ] as [AccessorDeclSyntax]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let initializer = binding.initializer?.value else {
            throw MacroError.invalidDeclaration
        }

        let peerDecl: DeclSyntax = "private var _\(raw: identifier) = \(initializer)"
        return [peerDecl]
    }
}
