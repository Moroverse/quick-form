//
//  WarningView.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 8.9.24..
//

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
