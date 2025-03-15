// DefaultDocumentUploader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:17 GMT.

import Factory
import Foundation

extension Container {
    final class DefaultDocumentUploader: DocumentUploader {
        func upload(from url: URL) async throws -> URL {
            try await Task.sleep(for: .seconds(2))
            return url
        }
    }

    final class FailingDocumentUploader: DocumentUploader {
        func upload(from url: URL) async throws -> URL {
            try await Task.sleep(for: .seconds(2))
            throw URLError(.badServerResponse)
        }
    }

    var documentUploader: Factory<DocumentUploader> {
        self { DefaultDocumentUploader() }
    }
}
