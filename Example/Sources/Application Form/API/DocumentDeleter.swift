// DocumentDeleter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:02 GMT.

import Foundation

protocol DocumentDeleter {
    func deleteDocument(from url: URL) async throws
}
