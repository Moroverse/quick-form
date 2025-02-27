// FormMultiPickerSection.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

import SwiftUI

public struct FormMultiPickerSection<Property: Hashable & CustomStringConvertible>: View {
    @Bindable private var viewModel: MultiPickerFieldViewModel<Property>

    public var body: some View {
        Section {
            ForEach(viewModel.allValues, id: \.hashValue) { item in
                Button {
                    if viewModel.value.contains(item) {
                        viewModel.value.remove(item)
                    } else {
                        viewModel.value.insert(item)
                    }
                } label: {
                    Label(item.description, systemImage: imageNameForItem(item))
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text(viewModel.title)
        }
    }

    public init(_ viewModel: MultiPickerFieldViewModel<Property>) {
        self.viewModel = viewModel
    }

    private func imageNameForItem(_ item: Property) -> String {
        if viewModel.value.contains(item) {
            "checkmark.circle"
        } else {
            "circle"
        }
    }
}

enum Animal: CustomStringConvertible, Hashable {
    case cat
    case dog
    case bird

    var description: String {
        switch self {
        case .cat: "Cat"
        case .dog: "Dog"
        case .bird: "Bird"
        }
    }
}

#Preview {
    @Previewable @State var form = MultiPickerFieldViewModel(value: [], allValues: [Animal.bird, .cat, .dog])

    Form {
        FormMultiPickerSection(form)
    }
}
