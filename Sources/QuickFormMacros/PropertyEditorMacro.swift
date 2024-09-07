// PropertyEditorMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PropertyEditorMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // This macro doesn't need to add any accessors
        []
    }
}
