// DocumentBrowser.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import Foundation
import SwiftUI
#if canImport(UIKit)
    import UIKit

    struct DocumentBrowser: UIViewControllerRepresentable {
        let model: DocumentBrowserModel

        class Coordinator: NSObject, UIDocumentPickerDelegate {
            var parent: DocumentBrowser

            init(parent: DocumentBrowser) {
                self.parent = parent
            }

            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                parent.model.urls = urls
                parent.model.didComplete?()
            }

            func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
                parent.model.urls = []
                parent.model.didComplete?()
            }
        }

        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let viewController = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            viewController.allowsMultipleSelection = false
            viewController.delegate = context.coordinator
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
    }
#endif

#Preview {
    DocumentBrowser(model: .init())
}
