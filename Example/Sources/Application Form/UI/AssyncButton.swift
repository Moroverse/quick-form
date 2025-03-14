// AssyncButton.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:25 GMT.

import SwiftUI

extension AsyncButton {
    enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }
}

struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    var actionOptions = Set(ActionOption.allCases)
    @ViewBuilder var label: () -> Label

    @State private var isDisabled = false
    @State private var showProgressView = false

    var body: some View {
        Button(
            action: {
                if actionOptions.contains(.disableButton) {
                    isDisabled = true
                }

                Task {
                    var progressViewTask: Task<Void, Error>?

                    if actionOptions.contains(.showProgressView) {
                        progressViewTask = Task {
                            try await Task.sleep(nanoseconds: 150_000_000)
                            showProgressView = true
                        }
                    }

                    await action()
                    progressViewTask?.cancel()

                    isDisabled = false
                    showProgressView = false
                }
            },
            label: {
                ZStack {
                    label().opacity(showProgressView ? 0 : 1)

                    if showProgressView {
                        ProgressView()
                    }
                }
            }
        )
        .disabled(isDisabled)
    }

    init(action: @escaping () async -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
}

extension AsyncButton where Label == Text {
    init(
        _ label: String,
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        action: @escaping () async -> Void
    ) {
        self.init(action: action) {
            Text(label)
        }
    }
}

extension AsyncButton where Label == Image {
    init(
        systemImageName: String,
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        action: @escaping () async -> Void
    ) {
        self.init(action: action) {
            Image(systemName: systemImageName)
        }
    }
}
