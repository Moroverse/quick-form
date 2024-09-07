// Macros.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

@attached(member, names: named(model), named(init), named(track))
public macro QuickForm<T>(_ type: T.Type) = #externalMacro(module: "QuickFormMacros", type: "QuickFormMacro")

@attached(accessor, names: named(willSet))
public macro PropertyEditor(keyPath: Any) = #externalMacro(module: "QuickFormMacros", type: "PropertyEditorMacro")
