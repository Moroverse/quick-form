// PreviewController.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:59 GMT.

import QuickLook
import SwiftUI

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
