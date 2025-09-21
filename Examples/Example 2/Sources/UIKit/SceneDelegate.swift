// SceneDelegate.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-09-13 08:03 GMT.

import ApplicationForm
import FactoryKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var mainCoordinator: AppCoordinator?
    lazy var model = ApplicationFormModel(
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
        ),
        dependencies: .init(
            additionalInfoDependencies: .init(
                documentUploader: Container.shared.documentUploader(),
                documentDeleter: Container.shared.documentDeleter(),
                router: { Container.shared.additionalInfoRouting() }
            ),
            addressModelDependencies: .init(
                stateLoader: Container.shared.stateLoader(),
                countryLoader: Container.shared.countryLoader()
            ),
            router: { Container.shared.applicationFormRouting() }
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

        let mainCoordinator = CoordinatorFactory.makeMainCoordinator(window: window)
        self.mainCoordinator = mainCoordinator
        Container.shared.additionalInfoRouting.register { mainCoordinator }
        Container.shared.applicationFormRouting.register { mainCoordinator }

        mainCoordinator.start(with: model)
    }
}
