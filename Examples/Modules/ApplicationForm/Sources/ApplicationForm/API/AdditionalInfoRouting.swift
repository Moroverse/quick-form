// AdditionalInfoRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import FactoryKit
import Foundation

public protocol AdditionalInfoRouting {
    func navigateToResumeUpload() async -> URL?
    func navigateToPreview(at url: URL)
}

public extension Container {
    var additionalInfoRouting: Factory<AdditionalInfoRouting?> { promised() }
}
