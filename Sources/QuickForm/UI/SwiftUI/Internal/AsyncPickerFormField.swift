// AsyncPickerFormField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-16 05:43 GMT.

import SwiftUI

protocol AsyncPickerStyle: View {
    associatedtype Label: View
    associatedtype Content: View

    var title: LocalizedStringResource { get }
    var content: () -> Content { get }
    var label: () -> Label { get }

    init(title: LocalizedStringResource, content: @escaping () -> Content, label: @escaping () -> Label)
}

struct AsyncPickerNavigationStyle<Label: View, Content: View>: View, AsyncPickerStyle {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label

    var body: some View {
        NavigationLink {
            content()
                .navigationTitle(String(localized: title))
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            label()
        }
    }

    init(title: LocalizedStringResource, content: @escaping () -> Content, label: @escaping () -> Label) {
        self.title = title
        self.content = content
        self.label = label
    }
}

struct AsyncPickerPopoverStyle<Label: View, Content: View>: View, AsyncPickerStyle {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label
    @State private var isPresented = false

    var body: some View {
        Button(action: {}, label: label)
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onTapGesture {
            isPresented = true
        }
        .popover(isPresented: $isPresented) {
            NavigationStack {
                content()
                    .navigationTitle(String(localized: title))
                    .navigationBarTitleDisplayMode(.inline)
            }
            .frame(minWidth: 300, minHeight: 400)
        }
    }

    init(title: LocalizedStringResource, content: @escaping () -> Content, label: @escaping () -> Label) {
        self.title = title
        self.content = content
        self.label = label
    }
}

struct AsyncPickerFormField<Label: View, Content: View>: View {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label
    @State private var style: AsyncPickerStyleConfiguration = .navigation

    var body: some View {
        Group {
            switch style {
            case .navigation:
                AsyncPickerNavigationStyle(title: title, content: content, label: label)

            case .popover:
                AsyncPickerPopoverStyle(title: title, content: content, label: label)

            case .inline:
                content()
            }
        }
    }

    init(
        title: LocalizedStringResource,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.title = title
        self.content = content
        self.label = label
    }

    func asyncPickerStyle(_ style: AsyncPickerStyleConfiguration) -> Self {
        var view = self
        view._style = State(initialValue: style)
        return view
    }
}
