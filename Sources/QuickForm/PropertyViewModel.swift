// PropertyViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Observation

@Observable
public final class PropertyViewModel<Property>: ValueEditor {
    public var title: String
    public var placeholder: String?
    public var value: Property

    public init(
        value: Property,
        title: String = "",
        placeholder: String? = nil
    ) {
        self.value = value
        self.title = title
        self.placeholder = placeholder
    }
}
