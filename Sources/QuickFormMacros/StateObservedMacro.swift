// StateObservedMacro.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-12 20:55 GMT.

import SwiftSyntax
import SwiftSyntaxMacros

/// A macro that generates observation tracking code for a property.
///
/// This macro transforms a simple property declaration into a fully observable property
/// with proper observation tracking, providing state observation capabilities.
public struct StateObservedMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              binding.initializer != nil else {
            throw MacroError.invalidDeclaration
        }

        let propertyName = identifier.text
        let backingPropertyName = "_\(propertyName)"

        return try [
            AccessorDeclSyntax("@storageRestrictions(initializes: \(raw: backingPropertyName))"),
            AccessorDeclSyntax("init(initialValue)") {
                ExprSyntax("\(raw: backingPropertyName) = initialValue")
            },

            AccessorDeclSyntax("get") {
                ExprSyntax("access(keyPath: \\.\(raw: propertyName))")
                ReturnStmtSyntax(expression: ExprSyntax("\(raw: backingPropertyName)"))
            },

            AccessorDeclSyntax("set") {
                ExprSyntax("""
                withMutation(keyPath: \\.\(raw: propertyName)) {
                    \(raw: backingPropertyName) = newValue
                }
                """)
            },

            AccessorDeclSyntax("_modify") {
                ExprSyntax("access(keyPath: \\.\(raw: propertyName))")
                ExprSyntax("_$observationRegistrar.willSet(self, keyPath: \\.\(raw: propertyName))")
                DeferStmtSyntax {
                    ExprSyntax("_$observationRegistrar.didSet(self, keyPath: \\.\(raw: propertyName))")
                }
                ExprSyntax("yield &\(raw: backingPropertyName)")
            }
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let initializer = binding.initializer else {
            throw MacroError.invalidDeclaration
        }

        let propertyName = identifier.text
        let backingPropertyName = "_\(propertyName)"
        let typeAnnotation = binding.typeAnnotation
        let initializerValue = initializer.value

        // Create the backing storage property
        // private var _propertyName: Type = initialValue
        let backingProperty: DeclSyntax = if let typeAnnotation {
            """
            private var \(raw: backingPropertyName)\(raw: typeAnnotation) = \(initializerValue)
            """
        } else {
            """
            private var \(raw: backingPropertyName) = \(initializerValue)
            """
        }

        return [backingProperty]
    }
}
