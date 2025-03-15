// DefaultDocumentDeleter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:17 GMT.

import Factory
import Foundation

extension Container {
    private final class DefaultDocumentDeleter: DocumentDeleter {
        func deleteDocument(from url: URL) async throws {}
    }

    private final class FailingDocumentDeleter: DocumentDeleter {
        func deleteDocument(from url: URL) async throws {
            try await Task.sleep(for: .seconds(3))
            throw URLError(.badServerResponse)
        }
    }

    var documentDeleter: Factory<DocumentDeleter> {
        self { FailingDocumentDeleter() }
    }
}
