// AdditionalInfo.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:00 GMT.

import Foundation

public struct AdditionalInfo {
    public var resume: URL?
    public var coverLetter: String?
    public var howDidYouHear: String?
    public var additionalNotes: String?
    public var consentToBackgroundChecks: Bool

    public init(resume: URL? = nil, coverLetter: String? = nil, howDidYouHear: String? = nil, additionalNotes: String? = nil, consentToBackgroundChecks: Bool) {
        self.resume = resume
        self.coverLetter = coverLetter
        self.howDidYouHear = howDidYouHear
        self.additionalNotes = additionalNotes
        self.consentToBackgroundChecks = consentToBackgroundChecks
    }
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
