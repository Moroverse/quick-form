// DismissibleButton.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 20:26 GMT.

import SwiftUI

struct DismissibleButton<Label: View>: View {
    private let actionHandler: (() -> Void)?
    private let label: () -> Label
    private let dismissible: Bool
    var onDismissHandler: (() -> Void)?
    var body: some View {
        Button {
            actionHandler?()
        } label: {
            if dismissible {
                HStack(spacing: 5) {
                    label()
                    Button {
                        onDismissHandler?()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .padding(.trailing, -5)
                    .buttonStyle(.plain)
                }
            } else {
                label()
            }
        }
    }

    init(dismissible: Bool = true, action: (() -> Void)?, @ViewBuilder label: @escaping () -> Label) {
        actionHandler = action
        self.label = label
        self.dismissible = dismissible
    }

    func onDismiss(_ handler: (() -> Void)?) -> Self {
        var selfCopy = self
        selfCopy.onDismissHandler = handler
        return selfCopy
    }
}

#Preview {
    DismissibleButton {} label: {
        Text("Hello")
    }
    .onDismiss {
        //
    }
}

#Preview {
    DismissibleButton(dismissible: false) {} label: {
        Text("Hello")
    }
}
