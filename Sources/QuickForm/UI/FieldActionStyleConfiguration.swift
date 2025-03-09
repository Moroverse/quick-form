// FieldActionStyleConfiguration.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-16 05:43 GMT.

public enum FieldActionStyleConfiguration {
    case navigation
    case popover
    case sheet
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        case fullScreen
    #endif
    case inline
}
