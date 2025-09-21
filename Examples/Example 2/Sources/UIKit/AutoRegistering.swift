// AutoRegistering.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-09-13 08:03 GMT.

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
