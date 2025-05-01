// DefaultDocumentUploader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 15:44 GMT.

import ApplicationForm
import Factory
import Foundation

final class DefaultDocumentUploader: DocumentUploader {
    func upload(from url: URL) async throws -> URL {
        try await Task.sleep(for: .seconds(2))
        return url
    }
}
