//
//  FormTextEditor.swift
//  QuickForm
//
//  Created by Daniel Moro on 4.3.25..
//

import SwiftUI

public struct FormTextEditor: View {
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String>
    @State private var hasError: Bool
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if hasTitle {
                Text(viewModel.title)
                    .font(.headline)
            }
            TextEditor(text: bindableValue)
                .focused($isFocused)
                .foregroundColor(shouldShowPlaceholder ? .secondary : .primary)
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

    public init(viewModel: FormFieldViewModel<String>) {
        self.viewModel = viewModel
        hasError = viewModel.errorMessage != nil
    }

    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    private var bindableValue: Binding<String> {
        if shouldShowPlaceholder {
            return .constant(String(localized: viewModel.placeholder ?? ""))
        }

        if viewModel.isReadOnly {
            return .constant(viewModel.value)
        } else {
            return $viewModel.value
        }
    }

    private var shouldShowPlaceholder: Bool {
        isFocused == false && viewModel.value.isEmpty
    }
}

#Preview("Default") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "Dogs",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}

#Preview("Placeholder") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "",
        title: "Dogs",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}

#Preview("Not Title") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}

#Preview("Read only") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa",
        title: "",
        placeholder: "John",
        isReadOnly: true
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}
