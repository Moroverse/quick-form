// SceneDelegate.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 23:02 GMT.

import ApplicationForm
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var model = ApplicationFormModel(
        value: .init(
            personalInformation: .init(
                givenName: "",
                familyName: "",
                email: "",
                phoneNumber: "",
                address: .init(
                    street: "",
                    city: "",
                    zipCode: ""
                )
            ),
            professionalDetails: .init(
                desiredPosition: "",
                desiredSalary: 0,
                availabilityDate: .distantPast,
                employmentType: [],
                willingToRelocate: false
            ),
            experience: .init(
                years: 0,
                skills: []
            ),
            education: [],
            additionalInfo: .init(consentToBackgroundChecks: false)
        )
    )

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window

        // MARK: - Main Flow Assembly

        let viewController = ApplicationFormComposer.composeController(with: model)
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
