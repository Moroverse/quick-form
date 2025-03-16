// DocumentUploader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Factory
import Foundation

public protocol DocumentUploader {
    func upload(from url: URL) async throws -> URL
}

public extension Container {
    private struct Dummy: DocumentUploader {
        func upload(from url: URL) async throws -> URL {
            url
        }
    }

    var documentUploader: Factory<DocumentUploader> {
        self {
            Dummy()
        }
    }
}
