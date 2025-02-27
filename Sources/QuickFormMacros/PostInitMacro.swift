// PostInitMacro.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-22 05:56 GMT.

import SwiftSyntax

// import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PostInitMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro doesn't add any peers, it's just used as a marker
        []
    }
}
