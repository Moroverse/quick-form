// FormAsyncPickerField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-15 18:18 GMT.

import SwiftUI

/// A SwiftUI view that represents an asynchronously-loaded picker field in a form.
///
/// `FormAsyncPickerField` is designed to work with `AsyncPickerFieldViewModel` to provide
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
/// ## Example
///
/// ```swift
/// struct MedicationForm: View {
///     @State private var viewModel = AsyncPickerFieldViewModel<[Medication], String>(
///         value: nil,
///         title: "Medication:",
///         valuesProvider: { query in
///             // Fetch medications matching the query
///             try await MedicationAPI.shared.search(query: query)
///         },
///         queryBuilder: { $0 ?? "" }
///     )
///
///     var body: some View {
///         Form {
///             FormAsyncPickerField(
///                 viewModel,
///                 clearValueMode: .always,
///                 pickerStyle: .navigation,
///                 allowSearch: true
///             ) { medication in
///                 // How to display the selected value
///                 HStack {
///                     Text("Medication:")
///                         .font(.headline)
///                     Spacer()
///                     Text(medication?.name ?? "None selected")
///                 }
///             } pickerContent: { medication in
///                 // How to display each item in the picker
///                 VStack(alignment: .leading) {
///                     Text(medication.name)
///                         .font(.headline)
///                     Text(medication.description)
///                         .font(.caption)
///                 }
///             }
///         }
///     }
/// }
/// ```
public struct FormAsyncPickerField<Model: RandomAccessCollection, Query, VContent: View, PContent: View>: View
    where Model: Sendable, Model.Element: Identifiable, Query: Sendable & Equatable {
    @Bindable private var viewModel: AsyncPickerFieldViewModel<Model, Query>
    @State private var hasError: Bool
    @State private var isPresented = false
    private let clearValueMode: ClearValueMode
    private let pickerStyle: AsyncPickerStyleConfiguration
    private let allowSearch: Bool
    private let valueContent: (Model.Element?) -> VContent
    private let pickerContent: (Model.Element) -> PContent

    /// Initializes a new `FormAsyncPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state and data loading for this picker field.
    ///   - clearValueMode: Determines when the clear button should be displayed. Defaults to `.never`.
    ///   - pickerStyle: The presentation style for the picker (navigation, popover, or inline). Defaults to `.popover`.
    ///   - allowSearch: Whether to include a search field for filtering the picker options. Defaults to `true`.
    ///   - valueContent: A closure that returns the view to display for the selected value.
    ///   - pickerContent: A closure that returns the view to display for each item in the picker.
    public init(
        _ viewModel: AsyncPickerFieldViewModel<Model, Query>,
        clearValueMode: ClearValueMode = .never,
        pickerStyle: AsyncPickerStyleConfiguration = .popover,
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
                AsyncPickerFormField(title: viewModel.title) {
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
                .asyncPickerStyle(pickerStyle)
            }

            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            withAnimation {
                hasError = newValue != nil
            }
        }
    }

    private var shouldDisplayPlaceholder: Bool {
        if case .none = viewModel.value {
            hasPlaceholder
        } else {
            false
        }
    }

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

    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    private var hasPlaceholder: Bool {
        let value = String(localized: viewModel.placeholder ?? "")
        return value.isEmpty == false
    }
}
