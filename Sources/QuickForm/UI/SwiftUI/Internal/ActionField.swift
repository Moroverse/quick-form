// ActionField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-06 05:33 GMT.

import SwiftUI

protocol FieldActionStyle: View {
    associatedtype Label: View
    associatedtype Content: View

    var title: LocalizedStringResource { get }
    var content: () -> Content { get }
    var label: () -> Label { get }

    init(title: LocalizedStringResource, content: @escaping () -> Content, label: @escaping () -> Label)
}

struct SafeNavigationBarTitleDisplayModeModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
            content
        #else
            content
                .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct FieldActionNavigationStyle<Label: View, Content: View>: View, FieldActionStyle {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label

    var body: some View {
        NavigationLink {
            content()
                .navigationTitle(String(localized: title))
                .modifier(SafeNavigationBarTitleDisplayModeModifier())
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

struct FieldActionPopoverStyle<Label: View, Content: View>: View, FieldActionStyle {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label
    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented = true
        }, label: label)
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented = true
            }
            .popover(isPresented: $isPresented) {
                NavigationStack {
                    content()
                        .navigationTitle(String(localized: title))
                        .modifier(SafeNavigationBarTitleDisplayModeModifier())
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

struct FieldActionSheetStyle<Label: View, Content: View>: View, FieldActionStyle {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label
    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented = true
        }, label: label)
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented = true
            }
            .sheet(isPresented: $isPresented, content: {
                NavigationStack {
                    content()
                        .navigationTitle(String(localized: title))
                        .modifier(SafeNavigationBarTitleDisplayModeModifier())
                }
            })
    }

    init(title: LocalizedStringResource, content: @escaping () -> Content, label: @escaping () -> Label) {
        self.title = title
        self.content = content
        self.label = label
    }
}

struct FieldActionFullScreenCoverStyle<Label: View, Content: View>: View, FieldActionStyle {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label
    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented = true
        }, label: label)
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented = true
            }
            .fullScreenCover(isPresented: $isPresented, content: {
                NavigationStack {
                    content()
                        .navigationTitle(String(localized: title))
                        .modifier(SafeNavigationBarTitleDisplayModeModifier())
                }
            })
    }

    init(title: LocalizedStringResource, content: @escaping () -> Content, label: @escaping () -> Label) {
        self.title = title
        self.content = content
        self.label = label
    }
}

struct ActionField<Label: View, Content: View>: View {
    let title: LocalizedStringResource
    let content: () -> Content
    let label: () -> Label
    @State private var actionStyle: FieldActionStyleConfiguration = .navigation

    var body: some View {
        Group {
            switch actionStyle {
            case .navigation:
                FieldActionNavigationStyle(title: title, content: content, label: label)

            case .popover:
                FieldActionPopoverStyle(title: title, content: content, label: label)

            case .inline:
                content()

            case .sheet:
                FieldActionSheetStyle(title: title, content: content, label: label)

            case .fullScreen:
                FieldActionFullScreenCoverStyle(title: title, content: content, label: label)
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

    func style(_ style: FieldActionStyleConfiguration) -> Self {
        var view = self
        view._actionStyle = State(initialValue: style)
        return view
    }
}
