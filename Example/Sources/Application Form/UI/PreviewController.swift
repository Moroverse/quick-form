// PreviewController.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import QuickLook
import SwiftUI

public enum PreviewComposer {
    public static func compose(with url: URL) -> some View {
        PreviewController(url: url)
    }
}

struct PreviewController: UIViewControllerRepresentable {
    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewController

        init(parent: PreviewController) {
            self.parent = parent
        }

        func numberOfPreviewItems(
            in controller: QLPreviewController
        ) -> Int {
            1
        }

        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            parent.url as NSURL
        }
    }

    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
