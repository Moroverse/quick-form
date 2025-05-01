// WarningView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 17:09 GMT.

import SwiftUI

enum WarningOptions {
    @MainActor
    static func warning() -> UIViewController {
        let controller = UIHostingController(rootView: WarningView())
        let navigationController = UINavigationController(rootViewController: controller)
        let closeButton = UIBarButtonItem(systemItem: .close, primaryAction: UIAction(handler: { _ in
            controller.dismiss(animated: true, completion: nil)
        }))
        controller.navigationItem.rightBarButtonItem = closeButton
        return navigationController
    }
}

struct WarningView: View {
    var body: some View {
        Text("This is not related controller that demonstrates navigation options")
    }
}

#Preview {
    WarningView()
}
