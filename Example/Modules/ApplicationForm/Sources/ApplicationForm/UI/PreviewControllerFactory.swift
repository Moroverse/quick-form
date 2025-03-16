//
//  PreviewControllerFactory.swift
//  ApplicationForm
//
//  Created by Daniel Moro on 16.3.25..
//

#if canImport(QuickLook)
import QuickLook

enum PreviewControllerFactory {
    private static let observeTokenKey = malloc(1)!
    class Coordinator: QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) {
            self.url = url
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
            url as NSURL
        }
    }

    static func make(with url: URL) -> QLPreviewController {
        let viewController = QLPreviewController()
        let coordinator = Coordinator(url: url)
        viewController.dataSource = coordinator
        objc_setAssociatedObject(viewController, Self.observeTokenKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
        return viewController
    }
}

#endif
