// Composers.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 06:44 GMT.

import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

public enum ApplicationFormComposer {
    public static func compose(with model: ApplicationFormModel) -> some View {
        ApplicationFormView(model: model)
    }

    #if canImport(UIKit)
        public static func composeController(with model: ApplicationFormModel) -> UIViewController {
            UIHostingController(rootView: compose(with: model))
        }
    #endif
}

public enum EducationFormComposer {
    public static func compose(with model: EducationModel, onDone: (() -> Void)? = nil) -> some View {
        EducationFormView(model: model, onDone: onDone)
    }

    #if canImport(UIKit)
        public static func composeController(with model: EducationModel, onDone: @escaping () -> Void) -> UIViewController {
            UIHostingController(rootView: compose(with: model, onDone: onDone))
        }
    #endif
}

public final class DocumentBrowserModel {
    public var urls: [URL]
    public var didComplete: (() -> Void)?

    public init(urls: [URL] = [], didComplete: (() -> Void)? = nil) {
        self.urls = urls
        self.didComplete = didComplete
    }
}

public enum DocumentBrowserComposer {
    public static func compose(with model: DocumentBrowserModel) -> some View {
        DocumentBrowser(model: model)
    }

    #if canImport(UIKit)
        public static func composeController(with model: DocumentBrowserModel) -> UIViewController {
            DocumentBrowserFactory.make(with: model)
        }
    #endif
}

public enum NewSkillFormComposer {
    public static func compose(with model: ExperienceSkillModel, onDone: (() -> Void)? = nil) -> some View {
        NewSkillView(model: model, onDone: onDone)
    }

    #if canImport(UIKit)
        public static func composeController(with model: ExperienceSkillModel, onDone: @escaping () -> Void) -> UIViewController {
            UIHostingController(rootView: compose(with: model, onDone: onDone))
        }
    #endif
}

public enum PreviewComposer {
    public static func compose(with url: URL) -> some View {
        PreviewController(url: url)
    }

    #if canImport(UIKit)
        public static func composeController(with url: URL) -> UIViewController {
            PreviewControllerFactory.make(with: url)
        }
    #endif
}
