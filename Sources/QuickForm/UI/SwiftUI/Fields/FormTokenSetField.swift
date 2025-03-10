// FormTokenSetField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 20:26 GMT.

import SwiftUI

public struct FormTokenSetField<Property: Identifiable & CustomStringConvertible>: View {
    @Bindable private var viewModel: TokenSetViewModel<Property>
    let columns = [GridItem(.adaptive(minimum: 100))]

    @State var newTag: String = ""
    public var body: some View {
        HStack(alignment: .center) {
            if let title = viewModel.title {
                Text(title)
                    .font(.headline)

                Divider()
            }

            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                    ForEach(viewModel.value) { code in
                        DismissibleButton(dismissible: viewModel.canDelete(code)) {
                            viewModel.selection = code.id
                        } label: {
                            Text(code.description)
                        }
                        .onDismiss { [id = code.id] in
                            withAnimation {
                                viewModel.remove(id: id)
                            }
                        }
                        .padding(.vertical, 1)
                        .buttonBorderShape(.capsule)
                        .modifier(ButtonToggleStyle(isSelected: code.id == viewModel.selection))
                    }
                    if viewModel.canInsert {
                        TextField(
                            "",
                            text: $newTag,
                            prompt: Text(String(localized: viewModel.insertionPlaceholder ?? ""))
                        )
                        .textFieldStyle(.plain)
                        .onSubmit {
                            withAnimation {
                                if viewModel.insert(newTag) {
                                    newTag = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    init(viewModel: TokenSetViewModel<Property>) {
        self.viewModel = viewModel
    }
}

struct ButtonToggleStyle: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        if isSelected {
            content
                .buttonStyle(.borderedProminent)
        } else {
            content
                .buttonStyle(.bordered)
        }
    }
}

struct Token: CustomStringConvertible, Identifiable {
    var id: String { description }
    var description: String
}

#Preview {
    @Previewable @State var model = TokenSetViewModel(
        value: [Token](),
        title: "Tokens",
        insertionPlaceholder: "Type here...",
        insertionMapper: { Token(description: $0)
        }
    )
    NavigationStack {
        Form {
            FormTokenSetField(viewModel: model)
        }
    }
}
