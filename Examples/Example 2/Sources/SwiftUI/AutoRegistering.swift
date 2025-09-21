// AutoRegistering.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-09-13 08:03 GMT.

import ApplicationForm
import FactoryKit

extension Container: @retroactive @MainActor AutoRegistering {
    @MainActor
    public func autoRegister() {
        documentDeleter.register { @MainActor in DefaultDocumentDeleter() }
        documentUploader.register { @MainActor in DefaultDocumentUploader() }
        stateLoader.register { @MainActor in DefaultStateLoader() }
        countryLoader.register { @MainActor in DefaultCountryLoader() }

        additionalInfoRouting.register { @MainActor in self.anyRouter() }
        applicationFormRouting.register { @MainActor in self.anyRouter() }
    }
}
