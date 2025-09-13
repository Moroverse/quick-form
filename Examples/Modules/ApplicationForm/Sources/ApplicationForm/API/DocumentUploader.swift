// DocumentUploader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import FactoryKit
import Foundation

public protocol DocumentUploader {
    func upload(from url: URL) async throws -> URL
}

public extension Container {
    struct DummyDocumentUploader: DocumentUploader {
        public func upload(from url: URL) async throws -> URL {
            url
        }
    }

    var documentUploader: Factory<DocumentUploader> {
        self {
            DummyDocumentUploader()
        }
    }
}
