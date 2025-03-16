// Composers.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 06:36 GMT.

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
    public static func compose(with model: EducationModel) -> some View {
        EducationFormView(model: model)
    }

    #if canImport(UIKit)
        public static func composeController(with model: EducationModel) -> UIViewController {
            UIHostingController(rootView: compose(with: model))
        }
    #endif
}

public final class DocumentBrowserModel {
    var urls: [URL] = []
    var didComplete: (() -> Void)?
}

public enum DocumentBrowserComposer {
    public static func compose(with model: DocumentBrowserModel) -> some View {
        DocumentBrowser(model: model)
    }
}

public enum NewSkillFormComposer {
    public static func compose(with model: ExperienceSkillModel) -> some View {
        NewSkillView(model: model)
    }

    #if canImport(UIKit)
        public static func composeController(with model: ExperienceSkillModel) -> UIViewController {
            UIHostingController(rootView: compose(with: model))
        }
    #endif
}

public enum PreviewComposer {
    public static func compose(with url: URL) -> some View {
        PreviewController(url: url)
    }
}
