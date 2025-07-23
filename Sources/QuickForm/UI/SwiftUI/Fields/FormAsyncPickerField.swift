// FormAsyncPickerField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-15 18:18 GMT.

import SwiftUI

/// A SwiftUI view that represents an asynchronously-loaded picker field in a form.
///
/// `FormAsyncPickerField` is designed to work with ``AsyncPickerFieldViewModel`` to provide
/// a picker interface for selecting values that are loaded asynchronously, such as from a network
/// request or a database query. This view is particularly useful for fields where the available
/// options need to be fetched on-demand rather than being statically defined.
///
/// ## Features
/// - Displays a customizable picker with asynchronously loaded options
/// - Supports various presentation styles (navigation, popover, inline)
/// - Allows customizing the appearance of both the selected value and picker items
/// - Provides search functionality for filtering large datasets
/// - Shows validation error messages when validation fails
/// - Supports optional clearing of the selected value
/// - Handles loading states and errors from asynchronous data sources
///
/// ## Example Usage
///
/// ### Basic Avatar Picker
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.avatar)
///     var avatar = AsyncPickerFieldViewModel(value: nil, title: "Avatar:") { query in
///         try await AvatarFetcher.shared.fetchAvatar(query: query)
///     } queryBuilder: { text in
///         text ?? ""
///     }
/// }
///
/// struct PersonEditView: View {
///     @Bindable var model: PersonEditModel
///
///     var body: some View {
///         Form {
///             FormAsyncPickerField(
///                 model.avatar,
///                 clearValueMode: .always,
///                 pickerStyle: .navigation
///             ) { selection in
///                 if let selection {
///                     Image(selection.imageName)
///                         .resizable()
///                         .frame(width: 88, height: 88)
///                         .clipShape(Circle())
///                 } else {
///                     VStack {
///                         Image(systemName: "person.crop.circle")
///                             .resizable()
///                             .frame(width: 88, height: 88)
///                         Text("No Person Avatar Selected")
///                     }
///                 }
///             } pickerContent: { avatar in
///                 HStack {
///                     Image(avatar.imageName)
///                         .resizable()
///                         .frame(width: 88, height: 88)
///                     Text(avatar.id.formatted())
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// ### Country/State Picker Relationship
///
/// ```swift
/// struct AddressForm: View {
///     @Bindable var model: AddressFormModel
///
///     var body: some View {
///         Form {
///             // Country picker
///             FormAsyncPickerField(
///                 model.country,
///                 pickerStyle: .menu,
///                 allowSearch: true
///             ) { country in
///                 Text(country?.name ?? "Select country")
///             } pickerContent: { country in
///                 Text(country.name)
///             }
///             .onAppear {
///                 Task {
///                     await model.country.search(model.country.queryBuilder(""))
///                 }
///             }
///
///             // State picker - only enabled when country is selected
///             if model.country.value != nil {
///                 FormAsyncPickerField(
///                     model.state,
///                     pickerStyle: .menu,
///                     allowSearch: true
///                 ) { state in
///                     Text(state?.name ?? "Select state/province")
///                 } pickerContent: { state in
///                     Text(state.name)
///                 }
///                 .disabled(model.country.value == nil)
///             }
///         }
///     }
/// }
/// ```
///
/// ### Handling Different Loading States
///
/// ```swift
/// FormAsyncPickerField(
///     viewModel.products,
///     clearValueMode: .whenNotEmpty,
///     allowSearch: true
/// ) { product in
///     Text(product?.name ?? "Select product")
/// } pickerContent: { product in
///     // Display picker content based on ModelState
///     switch viewModel.products.allValues {
///     case .initial:
///         Text("Search for products")
///     case .loading:
///         HStack {
///             Text("Loading...")
///             Spacer()
///             ProgressView()
///         }
///     case .loaded(let products) where products.isEmpty:
///         Text("No products found")
///     case .loaded:
///         Text(product.name)
///     case .error(let error):
///         Text("Error: \(error.localizedDescription)")
///             .foregroundColor(.red)
///     }
/// }
/// ```
///
/// - SeeAlso: ``AsyncPickerFieldViewModel``, ``ModelState``, ``ClearValueMode``, ``FieldActionStyleConfiguration``
public struct FormAsyncPickerField<Model: RandomAccessCollection, Query, VContent: View, PContent: View>: View
    where Model: Sendable, Model.Element: Identifiable, Query: Sendable & Equatable {
    @Bindable private var viewModel: AsyncPickerFieldViewModel<Model, Query>
    @State private var hasError: Bool
    @State private var isPresented = false
    private let clearValueMode: ClearValueMode
    private let pickerStyle: FieldActionStyleConfiguration
    private let allowSearch: Bool
    private let valueContent: (Model.Element?) -> VContent
    private let pickerContent: (Model.Element) -> PContent

    /// Initializes a new `FormAsyncPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``AsyncPickerFieldViewModel`` that manages the state and data loading for this picker field.
    ///   - clearValueMode: Determines when the clear button should be displayed. Defaults to `.never`.
    ///     - `.never`: Never show a clear button
    ///     - `.always`: Always show a clear button when a value is selected
    ///     - `.whenNotEmpty`: Show a clear button when a value is selected and the available values are not empty
    ///   - pickerStyle: The presentation style for the picker (navigation, popover, or inline). Defaults to `.popover`.
    ///   - allowSearch: Whether to include a search field for filtering the picker options. Defaults to `true`.
    ///   - valueContent: A closure that returns the view to display for the selected value.
    ///   - pickerContent: A closure that returns the view to display for each item in the picker.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormAsyncPickerField(
    ///     viewModel.country,
    ///     clearValueMode: .always,
    ///     pickerStyle: .navigation,
    ///     allowSearch: true
    /// ) { country in
    ///     Text(country?.name ?? "Select country")
    /// } pickerContent: { country in
    ///     HStack {
    ///         Text(country.name)
    ///         Spacer()
    ///         if country == viewModel.country.value {
    ///             Image(systemName: "checkmark")
    ///         }
    ///     }
    /// }
    /// ```
    public init(
        _ viewModel: AsyncPickerFieldViewModel<Model, Query>,
        clearValueMode: ClearValueMode = .never,
        pickerStyle: FieldActionStyleConfiguration = .popover,
        allowSearch: Bool = true,
        @ViewBuilder valueContent: @escaping (Model.Element?) -> VContent,
        @ViewBuilder pickerContent: @escaping (Model.Element) -> PContent
    ) {
        self.viewModel = viewModel
        self.clearValueMode = clearValueMode
        self.pickerStyle = pickerStyle
        self.allowSearch = allowSearch
        self.valueContent = valueContent
        self.pickerContent = pickerContent
        hasError = viewModel.errorMessage != nil
    }

    /// The body of the `FormAsyncPickerField` view.
    ///
    /// This view consists of:
    /// - A customizable presentation of the currently selected value
    /// - A picker interface that loads options asynchronously
    /// - Optional clear button for resetting the selection
    /// - Error message display when validation fails
    ///
    /// The picker's presentation style can be customized through the `pickerStyle` parameter,
    /// allowing for navigation-based, popover, or inline presentations depending on your needs.
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                ActionField(title: viewModel.title) {
                    AsyncPicker(
                        selectedValue: $viewModel.value,
                        allowSearch: allowSearch,
                        valuesProvider: viewModel.valuesProvider,
                        queryBuilder: viewModel.queryBuilder,
                        content: pickerContent
                    )
                } label: {
                    HStack {
                        valueContent(viewModel.value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if shouldDisplayClearButton {
                            Button {
                                viewModel.value = nil
                            } label: {
                                Image(systemName: "xmark.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .style(pickerStyle)
            }

            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: viewModel.validationResult) { _, newValue in
            withAnimation {
                hasError = newValue != .success
            }
        }
    }

    /// Determines whether to display a placeholder text instead of the selected value.
    ///
    /// Returns `true` if:
    /// - The current value is `nil`
    /// - A placeholder is provided in the view model
    private var shouldDisplayPlaceholder: Bool {
        if case .none = viewModel.value {
            hasPlaceholder
        } else {
            false
        }
    }

    /// Determines whether to display the clear button.
    ///
    /// The clear button visibility is controlled by:
    /// - The `clearValueMode` parameter
    /// - Whether a value is currently selected
    /// - The `isReadOnly` property of the view model
    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        switch clearValueMode {
        case .never:
            return false

        default:
            return viewModel.value != nil
        }
    }

    /// Checks if the view model has a non-empty title.
    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    /// Checks if the view model has a non-empty placeholder.
    private var hasPlaceholder: Bool {
        let value = String(localized: viewModel.placeholder ?? "")
        return value.isEmpty == false
    }
}

extension String: @retroactive Identifiable {
    nonisolated public var id: String { self }
}

#Preview("Basic") {
    @Previewable @State var picker = AsyncPickerFieldViewModel<[String], String>(
        value: nil,
        title: "Color",
        valuesProvider: { _ in ["Red", "Green", "Blue", "Yellow", "Purple"] },
        queryBuilder: { $0 ?? "" }
    )

    Form {
        FormAsyncPickerField(picker) { value in
            Text(value ?? "Select color")
        } pickerContent: { value in
            Text(value)
        }
    }
}

#Preview("With Search") {
    @Previewable @State var picker = AsyncPickerFieldViewModel<[String], String>(
        value: nil,
        title: "Color",
        valuesProvider: { query in
            let colors = ["Red", "Green", "Blue", "Yellow", "Purple"]
            if query.isEmpty {
                return colors
            }
            return colors.filter { $0.localizedCaseInsensitiveContains(query) }
        },
        queryBuilder: { $0 ?? "" }
    )

    Form {
        FormAsyncPickerField(picker, allowSearch: true) { value in
            Text(value ?? "Select color")
        } pickerContent: { value in
            Text(value)
        }
    }
}
