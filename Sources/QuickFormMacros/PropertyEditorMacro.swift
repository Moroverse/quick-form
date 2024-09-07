// PropertyEditorMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PropertyEditorMacro: AccessorMacro {
    public static func expansion<
        Context: MacroExpansionContext,
        Declaration: DeclSyntaxProtocol
    >(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: Declaration,
        in context: Context
    ) throws -> [AccessorDeclSyntax] {
        return []
    }

//    public static func expansion(
//        of node: AttributeSyntax,
//        providingAttributesFor declaration: some DeclGroupSyntax,
//        in context: some MacroExpansionContext
//    ) throws -> [AttributeSyntax] {
//        return [
//            AttributeSyntax(
//                attributeName: IdentifierTypeSyntax(name: .identifier("Observable"))
//            )
//        ]
//    }
}
