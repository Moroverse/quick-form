// DocumentUploader.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:52 GMT.

//
//  DocumentUploader.swift
//  Example
//
//  Created by Daniel Moro on 13.3.25..
//
import Foundation

protocol DocumentUploader {
    func upload(from url: URL) async throws -> URL
}
