// DefaultDocumentDeleter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:09 GMT.

import Factory
import Foundation

extension Container {
    private final class DefaultDocumentDeleter: DocumentDeleter {
        func deleteDocument(from url: URL) async throws {}
    }

    var documentDeleter: Factory<DocumentDeleter> {
        self { DefaultDocumentDeleter() }
    }
}
