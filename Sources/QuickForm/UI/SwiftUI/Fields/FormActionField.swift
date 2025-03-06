//
//  FormActionField.swift
//  quick-form
//
//  Created by Daniel Moro on 6.3.25..
//
import Foundation
import SwiftUI

public struct FormActionField<Property, Label: View, Content: View>: View {
    @Bindable private var viewModel: FormFieldViewModel<Property>
    @State private var hasError: Bool

    private let content: () -> Content
    private let label: (Property) -> Label
    private let presentationStyle: FieldActionStyleConfiguration

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ActionField(
                title: viewModel.title,
                content: content,
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
        @ViewBuilder content: @escaping () -> Content,
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
            FormActionField(form, style: .navigation) {} label: { value in
                Text(verbatim: value)
            }
        }
    }
}

#Preview("Popover") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .popover) {} label: { value in
                Text(verbatim: value)
            }
        }
    }
}

#Preview("Sheet") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .sheet) {} label: { value in
                Text(verbatim: value)
            }
        }
    }
}
