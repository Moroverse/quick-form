// FormAsyncActionField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 06:14 GMT.

import SwiftUI

public struct FormAsyncActionField<Property, Label: View>: View {
    #if DEBUG
        let inspection = Inspection<Self>()
    #endif
    @Bindable private var viewModel: FormFieldViewModel<Property>
    @State private var hasError: Bool
    @ViewBuilder private var label: (Property) -> Label
    private var action: () async -> Void
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            AsyncButton {
                await action()
            } label: {
                HStack(spacing: 10) {
                    if hasTitle {
                        Text(viewModel.title)
                            .accessibilityIdentifier("TITLE")
                            .font(.headline)
                    }

                    if IfOptionalNone() {
                        Text(viewModel.placeholder ?? "")
                            .foregroundStyle(.secondary)
                    } else {
                        label(viewModel.value)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

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
        .registerForInspection(inspection, in: self)
    }

    public init(viewModel: FormFieldViewModel<Property>, action: @escaping () async -> Void, @ViewBuilder label: @escaping (Property) -> Label) {
        self.viewModel = viewModel
        self.label = label
        self.action = action
        hasError = viewModel.errorMessage != nil
    }

    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    func IfOptionalNone() -> Bool {
        if let optional = viewModel.value as? any OptionalProtocol {
            if optional.wrappedValue == nil {
                true
            } else {
                false
            }
        } else {
            false
        }
    }
}

#Preview("Regular") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormAsyncActionField(
                viewModel: form) {
                    // async action
                } label: { value in
                    Text(value)
                }
        }
    }
}

#Preview("Placeholder") {
    @Previewable @State var form = FormFieldViewModel(value: String?.none, title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormAsyncActionField(
                viewModel: form) {
                    // async action
                } label: { value in
                    if let value {
                        Text(value)
                    }
                }
        }
    }
}
