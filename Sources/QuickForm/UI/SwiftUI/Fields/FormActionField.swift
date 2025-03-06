// FormActionField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-06 05:33 GMT.

//
//  FormActionField.swift
//  quick-form
//
//  Created by Daniel Moro on 6.3.25..
//
import Foundation
import SwiftUI

struct DismissableView<Content: View>: View {
    private let content: (DismissAction) -> Content
    @Environment(\.dismiss) private var dismiss
    public var body: some View {
        content(dismiss)
    }

    init(content: @escaping (DismissAction) -> Content) {
        self.content = content
    }
}

public struct FormActionField<Property, Label: View, Content: View>: View {
    @Bindable private var viewModel: FormFieldViewModel<Property>
    @State private var hasError: Bool

    private let content: (DismissAction) -> Content
    private let label: (Property) -> Label
    private let presentationStyle: FieldActionStyleConfiguration

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ActionField(
                title: viewModel.title,
                content: {
                    DismissableView(content: content)
                },
                label: {
                    label(viewModel.value)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            )
            .style(presentationStyle)

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

    public init(
        _ viewModel: FormFieldViewModel<Property>,
        style: FieldActionStyleConfiguration,
        @ViewBuilder content: @escaping (DismissAction) -> Content,
        @ViewBuilder label: @escaping (Property) -> Label
    ) {
        self.viewModel = viewModel
        self.content = content
        self.label = label
        presentationStyle = style

        hasError = viewModel.errorMessage != nil
    }
}

#Preview("Navigation") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .navigation) { _ in } label: { value in
                Text(verbatim: value)
            }
        }
    }
}

#Preview("Popover") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .popover) { _ in } label: { value in
                Text(verbatim: value)
            }
        }
    }
}

#Preview("Sheet") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .sheet) { _ in } label: { value in
                Text(verbatim: value)
            }
        }
    }
}
