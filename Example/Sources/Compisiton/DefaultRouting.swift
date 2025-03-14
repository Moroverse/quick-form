// DefaultRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:25 GMT.

import Factory

extension Container {
    var additionalInfoRouting: Factory<AdditionalInfoRouting?> {
        self { self.anyRouter() }
    }

    var applicationFormRouting: Factory<ApplicationFormRouting?> {
        self { self.anyRouter() }
    }
}
