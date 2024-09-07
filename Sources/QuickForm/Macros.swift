// Macros.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Observation

@attached(member, names: named(model), named(init), named(track), named(_$observationRegistrar), named(access), named(withMutation))
@attached(extension, conformances: Observable)
public macro QuickForm<T>(_ type: T.Type) = #externalMacro(module: "QuickFormMacros", type: "QuickFormMacro")

@attached(accessor, names: named(init), named(get), named(set), named(_modify))
@attached(peer, names: prefixed(`_`))
public macro PropertyEditor(keyPath: Any) = #externalMacro(module: "QuickFormMacros", type: "PropertyEditorMacro")
