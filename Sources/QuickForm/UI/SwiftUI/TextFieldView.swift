//
//  File.swift
//
//
//  Created by Daliborka Randjelovic on 5.1.23..
//

import SwiftUI

public struct TextFieldView: View {
    @FocusState private var isFocused: Bool
    @State private var alignment: TextAlignment = .trailing
    @Bindable private var viewModel: PropertyViewModel<String>

    public init(_ viewModel: PropertyViewModel<String>) {
        self.viewModel = viewModel
        isFocused = false
    }

    public var body: some View {
        HStack(spacing: 10) {
            Text(viewModel.title)
                .font(.headline)
            TextField(viewModel.placeholder ?? "", text: $viewModel.value)
                .focused($isFocused)
                .multilineTextAlignment(alignment)
                .disabled(viewModel.isReadOnly)
        }.onChange(of: isFocused) {
            alignment = isFocused ? .leading : .trailing
        }
    }
}

struct TextFieldView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var viewModel = PropertyViewModel(
            value: "Rasa",
            title: "Name",
            placeholder: "John",
            isReadOnly: false
        )

        var body: some View {
            TextFieldView(viewModel)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
