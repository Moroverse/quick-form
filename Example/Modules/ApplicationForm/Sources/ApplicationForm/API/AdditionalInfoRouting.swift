// AdditionalInfoRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Factory
import Foundation

public protocol AdditionalInfoRouting {
    func navigateToResumeUpload() async -> URL?
    @MainActor
    func navigateToPreview(at url: URL)
}

public extension Container {
    private struct Dummy: AdditionalInfoRouting {
        func navigateToResumeUpload() async -> URL? {
            nil
        }

        func navigateToPreview(at url: URL) {}
    }

    var additionalInfoRouting: Factory<AdditionalInfoRouting?> { promised() }
}
