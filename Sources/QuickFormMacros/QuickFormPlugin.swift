// QuickFormPlugin.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct QuickFormPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        QuickFormMacro.self,
        PropertyEditorMacro.self,
        PostInitMacro.self
    ]
}
