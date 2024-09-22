// FormAsyncPickerField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-15 18:18 GMT.

import SwiftUI

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
    /// Initializes a new `FormOptionalPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state of this picker field.
    ///   - pickerStyle: The style to apply to the picker. Defaults to `.menu`.
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

    /// The body of the `FormOptionalPickerField` view.
    ///
    /// This view consists of:
    /// - A picker with an optional "None" choice and all provided values
    /// - An error message (if validation fails)
    ///
    /// The picker's style can be customized through the `pickerStyle` parameter in the initializer.
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
