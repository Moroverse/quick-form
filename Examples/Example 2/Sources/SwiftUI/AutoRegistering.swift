// AutoRegistering.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 15:44 GMT.

import ApplicationForm
import FactoryKit

extension Container: @retroactive @MainActor AutoRegistering {
    @MainActor
    public func autoRegister() {
        documentDeleter.register { DefaultDocumentDeleter() }
        documentUploader.register { DefaultDocumentUploader() }
        stateLoader.register { DefaultStateLoader() }
        countryLoader.register { DefaultCountryLoader() }

        additionalInfoRouting.register { self.anyRouter() }
        applicationFormRouting.register { self.anyRouter() }
    }
}
