// AutoRegistering.swift
// Copyright (c) 2026 Moroverse
// Created by Daniel Moro on 2025-03-16 08:02 GMT.

import ApplicationForm
import FactoryKit

extension Container: @retroactive AutoRegistering {
    public func autoRegister() {
        documentDeleter.register { DefaultDocumentDeleter() }
        documentUploader.register { DefaultDocumentUploader() }
        stateLoader.register { DefaultStateLoader() }
        countryLoader.register { DefaultCountryLoader() }
    }
}
