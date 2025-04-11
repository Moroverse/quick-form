// DependencyMacro.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-04-11 04:45 GMT.

import SwiftSyntax

// import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DependencyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro doesn't add any peers, it's just used as a marker
        []
    }
}
