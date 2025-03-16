//
//  DocumentBrowserController.swift
//  ApplicationForm
//
//  Created by Daniel Moro on 16.3.25..
//
#if canImport(UIKit)
    import UIKit

    enum DocumentBrowserFactory {
        private static let observeTokenKey = malloc(1)!
        class Coordinator: NSObject, UIDocumentPickerDelegate {
            let model: DocumentBrowserModel

            init(model: DocumentBrowserModel) {
                self.model = model
            }

            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                model.urls = urls
                model.didComplete?()
            }

            func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
                model.urls = []
                model.didComplete?()
            }
        }

        static func make(with model: DocumentBrowserModel) -> UIDocumentPickerViewController {
            let coordinator = Coordinator(model: model)
            let viewController = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            viewController.allowsMultipleSelection = false
            viewController.delegate = coordinator
            objc_setAssociatedObject(viewController, Self.observeTokenKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            return viewController
        }
    }

#endif
