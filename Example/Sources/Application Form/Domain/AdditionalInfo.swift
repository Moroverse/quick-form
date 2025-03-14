// AdditionalInfo.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:13 GMT.

import Foundation

enum Resume {
    case missing
    case present(url: URL)
    case error(Error)
}

struct AdditionalInfo {
    var resume: Resume
}

#if DEBUG
    extension AdditionalInfo {
        static let sample = AdditionalInfo(resume: .missing)
    }
#endif
