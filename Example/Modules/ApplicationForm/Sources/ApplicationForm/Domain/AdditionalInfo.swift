// AdditionalInfo.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation

struct AdditionalInfo {
    var resume: URL?
    var coverLetter: String?
    var howDidYouHear: String?
    var additionalNotes: String?
    var consentToBackgroundChecks: Bool
}

#if DEBUG
    extension AdditionalInfo {
        static let sample = AdditionalInfo(
            resume: nil,
            coverLetter: nil,
            howDidYouHear: nil,
            additionalNotes: nil,
            consentToBackgroundChecks: false
        )
    }
#endif
