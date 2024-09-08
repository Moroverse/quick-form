// FormattedFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Foundation
import Observation

@Observable
public final class FormattedFieldViewModel<F>: ValueEditor where F: ParseableFormatStyle, F.FormatOutput == String {
    public var title: LocalizedStringResource
    public var placeholder: LocalizedStringResource?
    public var format: F
    public var value: F.FormatInput
    public var isReadOnly: Bool

    public init(
        value: F.FormatInput,
        format: F,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false
    ) {
        self.value = value
        self.format = format
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
    }
}
