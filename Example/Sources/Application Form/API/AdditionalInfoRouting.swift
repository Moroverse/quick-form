// AdditionalInfoRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:24 GMT.

import Foundation

protocol AdditionalInfoRouting {
    func navigateToResumeUpload() async -> URL?
    @MainActor
    func navigateToPreview(at url: URL)
}
