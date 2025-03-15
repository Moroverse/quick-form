// AdditionalInfo.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:13 GMT.

import Foundation

struct AdditionalInfo {
    var resume: URL?
    var coverLetter: String?
    var howDidYouHear: String?
    var additionalNotes: String?
}

#if DEBUG
    extension AdditionalInfo {
        static let sample = AdditionalInfo(resume: nil, coverLetter: nil, howDidYouHear: nil, additionalNotes: nil)
    }
#endif
