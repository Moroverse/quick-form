// Experience.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 04:28 GMT.

struct Experience {
    var years: Int
}

#if DEBUG
    extension Experience {
        static var sample: Experience {
            .init(years: 1)
        }
    }
#endif
