// DefaultDocumentUploader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-09-13 08:03 GMT.

import ApplicationForm
import FactoryKit
import Foundation

final class DefaultDocumentUploader: DocumentUploader {
    func upload(from url: URL) async throws -> URL {
        try await Task.sleep(for: .seconds(2))
        return url
    }
}
