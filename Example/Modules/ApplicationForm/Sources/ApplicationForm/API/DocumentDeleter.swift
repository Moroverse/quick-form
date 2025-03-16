// DocumentDeleter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import Factory
import Foundation

public protocol DocumentDeleter {
    func deleteDocument(from url: URL) async throws
}

public extension Container {
    private struct Dummy: DocumentDeleter {
        func deleteDocument(from url: URL) async throws {}
    }

    var documentDeleter: Factory<DocumentDeleter> {
        self {
            Dummy()
        }
    }
}
