// MainCoordinator.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-17 08:12 GMT.

//
//  MainCoordinator.swift
//  Example
//
//  Created by Daniel Moro on 17.3.25..
//
import ApplicationForm
import Foundation
import UIKit

@MainActor
class AppCoordinator: NSObject {
    private let navigationController: UINavigationController
    private var childCoordinators: [AnyObject] = []
    private var onDismiss: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(with model: ApplicationFormModel) {
        let initialViewController = ApplicationFormComposer.composeController(with: model)
        navigationController.pushViewController(initialViewController, animated: false)
    }
}

extension AppCoordinator: ApplicationFormRouting, AdditionalInfoRouting {
    // MARK: - ApplicationFormRouting Implementation

    func navigateToNewSkill() async -> ExperienceSkill? {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(returning: nil)
                return
            }

            let model = ExperienceSkillModel(value: .init(id: UUID(), name: "", level: 0))
            let skillVC = NewSkillFormComposer.composeController(with: model) { [weak self] in
                if case let .committed(newValue) = model.state {
                    continuation.resume(returning: newValue)
                } else {
                    continuation.resume(returning: nil)
                }

                self?.navigationController.dismiss(animated: true)
            }

            let navController = UINavigationController(rootViewController: skillVC)

            navigationController.present(navController, animated: true)
        }
    }

    func navigateToEducation(_ selection: Education?) async -> Education? {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(returning: nil)
                return
            }

            let model = EducationModel(
                value: selection ?? Education(
                    id: UUID(),
                    institution: "",
                    startDate: Date(),
                    endDate: Date(),
                    degree: "",
                    fieldOfStudy: "",
                    gpa: 5
                )
            )
            let educationVC = EducationFormComposer.composeController(with: model) { [weak self] in
                if case let .committed(newValue) = model.state {
                    continuation.resume(returning: newValue)
                } else {
                    continuation.resume(returning: nil)
                }

                self?.navigationController.dismiss(animated: true)
            }

            let navController = UINavigationController(rootViewController: educationVC)

            navigationController.present(navController, animated: true)
        }
    }

    // MARK: - AdditionalInfoRouting Implementation

    func navigateToResumeUpload() async -> URL? {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(returning: nil)
                return
            }

            let model = DocumentBrowserModel()
            let resumeVC = DocumentBrowserComposer.composeController(with: model)

            model.didComplete = {
                continuation.resume(returning: model.urls.first)
            }

            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
            cancelButton.primaryAction = UIAction { _ in
                self.navigationController.dismiss(animated: true) {
                    continuation.resume(returning: nil)
                }
            }

            let navController = UINavigationController(rootViewController: resumeVC)
            resumeVC.navigationItem.leftBarButtonItem = cancelButton

            // Present as sheet
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.delegate = self
                onDismiss = {
                    continuation.resume(returning: nil)
                }
            }

            navigationController.present(navController, animated: true)
        }
    }

    @MainActor
    func navigateToPreview(at url: URL) {
        let previewVC = PreviewComposer.composeController(with: url)
        previewVC.modalPresentationStyle = .fullScreen

        navigationController.present(previewVC, animated: true)
    }
}

extension AppCoordinator: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss?()
    }
}

// MARK: - Factory for creating the coordinator

class CoordinatorFactory {
    @MainActor
    static func makeMainCoordinator(window: UIWindow) -> AppCoordinator {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let coordinator = AppCoordinator(navigationController: navigationController)
        return coordinator
    }
}
