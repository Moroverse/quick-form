// AsyncPickerFieldViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation
import Observation

/// Represents the loading state of asynchronously fetched data.
///
/// This enum tracks the different states of data being loaded asynchronously:
/// - `initial`: No loading has been attempted yet
/// - `loading`: Data is currently being fetched
/// - `loaded`: Data has been successfully loaded with the model
/// - `error`: An error occurred during loading
///
/// - SeeAlso: ``AsyncPickerFieldViewModel``
public enum ModelState<Model> {
    case initial
    case loading
    case loaded(Model)
    case error(Error)
}

/// A view model for picker fields that loads their values asynchronously.
///
/// `AsyncPickerFieldViewModel` manages a picker that fetches its available options from an asynchronous
/// data source such as a network API or database. It is designed to be used with ``FormAsyncPickerField``
/// to create dynamic picker interfaces that load data on demand.
///
/// ## Features
/// - Asynchronous loading of picker options
/// - Support for search/filtering of available options
/// - Tracking of loading state (initial, loading, loaded, error)
/// - Value selection and change notifications
/// - Validation support
///
/// ## Example with FormAsyncPickerField
///
/// ```swift
/// struct AddressView: View {
///     @Bindable var model: AddressModel
///
///     var body: some View {
///         FormAsyncPickerField(
///             model.country,
///             clearValueMode: .always,
///             pickerStyle: .popover,
///             allowSearch: true
///         ) {
///             // Display format for selected value
///             let placeholder = model.country.placeholder ?? ""
///             Text($0 ?? String(localized: placeholder))
///         } pickerContent: {
///             // Display format for each item in picker
///             Text($0)
///         }
///         .onAppear {
///             Task {
///                 // Load data when view appears
///                 await model.country.search(model.country.queryBuilder(""))
///             }
///         }
///     }
/// }
/// ```
///
/// ## Defining the Model
///
/// ```swift
/// @PropertyEditor(keyPath: \Address.country)
/// var country = AsyncPickerFieldViewModel(
///     type: String?.self,
///     placeholder: "Select Country...",
///     validation: .of(.required()),
///     valuesProvider: { [weak self] query in
///         guard let self else { return [] }
///         return try await countryLoader.loadCountries(query: query)
///     },
///     queryBuilder: { $0 ?? "" }
/// )
/// ```
///
/// ## Chaining Related Fields (Country/State Example)
///
/// ```swift
/// @PostInit
/// func configure() {
///     // When country changes, update states
///     country.onValueChanged { [weak self] newValue in
///         guard let self else { return }
///         // Clear state selection
///         state.value = nil
///
///         Task { [weak self] in
///             self?.hasStates = await self?.stateLoader.hasStates(country: self?.country.value ?? "") ?? false
///         }
///     }
///
///     // Set up state values provider to use the selected country
///     state.valuesProvider = { [weak self] query in
///         guard let self else { return [] }
///         return try await stateLoader.loadStates(country: query)
///     }
/// }
/// ```
///
/// ## Setting Up Preview Data
///
/// ```swift
/// struct AddressView_Previews: PreviewProvider {
///     struct MockCountryLoader: CountryLoader {
///         func loadCountries(query: String) async throws -> [String] {
///             ["Country #1", "Country #2", "Country #3"]
///         }
///     }
///
///     static var previews: some View {
///         let _ = Container.shared.countryLoader.register { MockCountryLoader() }
///         // Use the model in a preview
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormAsyncPickerField``, ``ObservableValueEditor``, ``Validatable``, ``Dispatcher``
@Observable
public final class AsyncPickerFieldViewModel<Model: Collection, Query>:
    ObservableValueEditor, Validatable where Model: Sendable, Query: Sendable & Equatable {
    /// The title of the picker field.
    public var title: LocalizedStringResource

    /// An optional placeholder text for the form field.
    ///
    /// This is displayed when no value is selected or when presenting
    /// the field in contexts that support placeholders.
    public var placeholder: LocalizedStringResource?

    /// A provider of all available values for the picker.
    ///
    /// This closure is called by the `search` method to asynchronously
    /// fetch values matching the given query. In the example of an address form,
    /// this might fetch a list of countries or states from an API.
    @ObservationIgnored
    public var valuesProvider: (Query) async throws -> Model

    /// Converts an optional string input to a query object.
    ///
    /// This is used to transform user search input into the appropriate query type
    /// needed by the `valuesProvider`. Typically implemented as:
    /// ```swift
    /// { $0 ?? "" } // For string-based queries
    /// ```
    @ObservationIgnored
    public var queryBuilder: (String?) -> Query

    /// The current state of available values for the picker.
    ///
    /// This property reflects the loading state and available options:
    /// - `.initial`: No search has been performed yet
    /// - `.loading`: A search is in progress
    /// - `.loaded(values)`: Values have been successfully loaded
    /// - `.error(error)`: An error occurred during loading
    ///
    /// When binding this model to a `FormAsyncPickerField`, this state automatically
    /// controls the UI state, showing loading indicators or error messages as appropriate.
    public var allValues: ModelState<Model>

    /// The currently selected value, which can be nil.
    ///
    /// When this value changes:
    /// - All subscribers registered via `onValueChanged(_:)` are notified
    /// - Validation is performed and `validationResult` is updated
    /// - The UI displaying this picker is automatically updated
    public var value: Model.Element? {
        didSet {
            dispatcher.publish(value)
            validationResult = validate()
        }
    }

    /// A boolean indicating whether the field is read-only.
    public var isReadOnly: Bool

    /// The validation rule to apply to the selected value.
    public var validation: AnyValidationRule<Model.Element?>?

    /// The current validation state of the field.
    private(set) var validationResult: ValidationResult = .success

    /// The dispatcher used to notify subscribers of value changes.
    private var dispatcher: Dispatcher

    /// Initializes a new instance of `AsyncPickerFieldViewModel`.
    ///
    /// - Parameters:
    ///   - value: The initial selected value, which can be nil.
    ///   - title: The title of the picker field.
    ///   - placeholder: An optional placeholder text for when no value is selected.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    ///   - valuesProvider: A closure that asynchronously provides values based on a query.
    ///   - queryBuilder: A closure that converts optional strings to query objects.
    ///
    /// ## Example
    /// ```swift
    /// AsyncPickerFieldViewModel(
    ///     value: nil,
    ///     title: "Country",
    ///     placeholder: "Select Country...",
    ///     validation: .of(.required()),
    ///     valuesProvider: { query in
    ///         try await countryLoader.loadCountries(query: query)
    ///     },
    ///     queryBuilder: { $0 ?? "" }
    /// )
    /// ```
    public init(
        value: Model.Element?,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Model.Element?>? = nil,
        valuesProvider: @escaping (Query) async throws -> Model,
        queryBuilder: @escaping (String?) -> Query
    ) {
        self.value = value
        self.valuesProvider = valuesProvider
        self.queryBuilder = queryBuilder
        self.title = title
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
        self.validation = validation
        dispatcher = Dispatcher()
        allValues = .initial
        validationResult = validate()
    }

    /// Performs validation on the current value.
    ///
    /// - Returns: A `ValidationResult` indicating whether the validation succeeded or failed.
    public func validate() -> ValidationResult {
        validation?.validate(value) ?? .success
    }

    /// Initiates an asynchronous search for values matching the given query.
    ///
    /// This method updates the `allValues` property to reflect the loading state:
    /// 1. Sets `allValues` to `.loading`
    /// 2. Calls the `valuesProvider` with the provided query
    /// 3. Updates `allValues` to either `.loaded(result)` or `.error(error)`
    ///
    /// - Parameter query: The query to search for
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Load all countries when view appears
    /// .onAppear {
    ///     Task {
    ///         await country.search(country.queryBuilder(""))
    ///     }
    /// }
    ///
    /// // Or with a specific search term
    /// .onSubmit {
    ///     Task {
    ///         await country.search(country.queryBuilder(searchText))
    ///     }
    /// }
    /// ```
    public func search(_ query: Query) async {
        allValues = .loading
        do {
            let model = try await valuesProvider(query)
            allValues = .loaded(model)
        } catch {
            allValues = .error(error)
        }
    }

    /// Sets a closure to be called when the value changes.
    ///
    /// - Parameter change: A closure that takes the new value as its parameter.
    /// - Returns: A `Subscription` that can be used to unsubscribe when needed.
    ///
    /// ## Example - Linking Country/State Fields
    ///
    /// ```swift
    /// country.onValueChanged { [weak self] newCountry in
    ///     guard let self = self else { return }
    ///
    ///     // Clear the state selection when country changes
    ///     state.value = nil
    ///
    ///     // Reload states for the new country
    ///     if let countryValue = newCountry {
    ///         Task {
    ///             await state.search(state.queryBuilder(countryValue))
    ///         }
    ///     }
    /// }
    /// ```
    @discardableResult
    public func onValueChanged(_ change: @escaping (Model.Element?) -> Void) -> Subscription {
        dispatcher.subscribe(handler: change)
    }
}

/// Convenience initializers for `AsyncPickerFieldViewModel` when the element type implements `DefaultValueProvider`.
public extension AsyncPickerFieldViewModel where Model.Element: DefaultValueProvider {
    /// Convenience initializer that uses the default value of the element type.
    ///
    /// - Parameters:
    ///   - type: The type of model elements.
    ///   - title: The title of the picker field.
    ///   - placeholder: An optional placeholder text for the form field.
    ///   - isReadOnly: A boolean indicating whether the field is read-only. Defaults to `false`.
    ///   - validation: An optional validation rule for the field.
    ///   - valuesProvider: A closure that provides values based on a query.
    ///   - queryBuilder: A closure that builds a query from an optional string.
    ///
    /// ## Example
    ///
    /// ```swift
    /// AsyncPickerFieldViewModel(
    ///     type: Country?.self,
    ///     title: "Country",
    ///     placeholder: "Select Country...",
    ///     validation: .of(.required()),
    ///     valuesProvider: { query in
    ///         try await countryLoader.loadCountries(query: query)
    ///     },
    ///     queryBuilder: { $0 ?? "" }
    /// )
    /// ```
    convenience init(
        type: Model.Element?.Type,
        title: LocalizedStringResource = "",
        placeholder: LocalizedStringResource? = nil,
        isReadOnly: Bool = false,
        validation: AnyValidationRule<Model.Element?>? = nil,
        valuesProvider: @escaping (Query) async throws -> Model,
        queryBuilder: @escaping (String?) -> Query
    ) {
        self.init(
            value: Model.Element.defaultValue,
            title: title,
            placeholder: placeholder,
            isReadOnly: isReadOnly,
            validation: validation,
            valuesProvider: valuesProvider,
            queryBuilder: queryBuilder
        )
    }
}
