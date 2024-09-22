// AsyncPickerFieldViewModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-15 18:18 GMT.

import Foundation
import Observation

public enum ModelState<Model> {
    case initial
    case loading
    case loaded(Model)
    case error(Error)
}

@Observable
public final class AsyncPickerFieldViewModel<Model: Collection, Query>:
    ValueEditor, Validatable where Model: Sendable, Query: Sendable & Equatable {
    /// The title of the picker field.
    public var title: LocalizedStringResource
    /// An optional placeholder text for the form field.
    public var placeholder: LocalizedStringResource?
    /// An provider of all available values for the picker.
    @ObservationIgnored
    public var valuesProvider: (Query) async throws -> Model
    @ObservationIgnored
    public var queryBuilder: (String) -> Query
    /// An array of all available values for the picker.
    public var allValues: ModelState<Model>
    /// The currently selected value, which can be nil.
    public var value: Model.Element? {
        didSet {
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool
    /// The validation rule to apply to the selected value.
    public var validation: AnyValidationRule<Model.Element?>?

    private var validationResult: ValidationResult = .success

    /// Initializes a new instance of `OptionalPickerFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial selected value, which can be nil.
    ///   - allValues: An array of all available values for the picker.
    ///   - title: The title of the picker field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    public init(
        value: Model.Element?,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Model.Element?>? = nil,
        valuesProvider: @escaping (Query) async throws -> Model,
        queryBuilder: @escaping (String) -> Query
    ) {
        self.value = value
        self.valuesProvider = valuesProvider
        self.queryBuilder = queryBuilder
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        allValues = .initial
        validationResult = validate()
    }

    /// Performs validation on the current value.
    ///
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }

    public func search(_ query: Query) async {
        allValues = .loading
        do {
            let model = try await valuesProvider(query)
            allValues = .loaded(model)
        } catch {
            allValues = .error(error)
        }
    }
}
