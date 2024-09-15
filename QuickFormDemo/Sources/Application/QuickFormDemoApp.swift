// QuickFormDemoApp.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 17:09 GMT.

import QuickForm
import SwiftUI
import UIKitNavigation

let fakePerson = Person(
    givenName: "Olivia",
    familyName: "Chen",
    dateOfBirth: Date(timeIntervalSince1970: 707_443_200), // September 3, 1992
    sex: .female,
    phone: "5551234567",
    salary: 75000.00,
    weight: Measurement(value: 58.5, unit: UnitMass.kilograms),
    isEstablished: true,
    address: Address(
        line1: "742 Evergreen Terrace",
        line2: "Apartment 3B",
        city: "Springfield",
        zipCode: "12345",
        country: .unitedStates,
        state: .unitedStates(.california)
    )
)

private final class PresentationDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    let didDismiss: () -> Void

    init(didDismiss: @escaping () -> Void) {
        self.didDismiss = didDismiss
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        didDismiss()
    }

    static let observeTokenKey = malloc(1)!
}

@MainActor
func initialController() -> UIViewController {
    let navigationController = UINavigationController()
    let delegate = PersonEditorDelegate {
        let warning = WarningOptions.warning()
        navigationController.present(warning, animated: true)
    } didTapOnAddTeamMember: { completion in
        let delegate = PersonSearchViewDelegate { personInfo in
            completion(personInfo)
            navigationController.dismiss(animated: true)
        }
        let personSearch = PersonSearch.personSearch(delegate: delegate)
        let presentationDelegate = PresentationDelegate(didDismiss: {
            completion(nil)
        })
        objc_setAssociatedObject(personSearch, PresentationDelegate.observeTokenKey, presentationDelegate, .OBJC_ASSOCIATION_RETAIN)

        personSearch.presentationController?.delegate = presentationDelegate
        navigationController.present(personSearch, animated: true)
    }

    let editor = PersonEditor.personEditor(for: fakePerson, delegate: delegate)
    navigationController.pushViewController(editor, animated: false)
    return navigationController
}

@main
struct QuickFormDemoApp: App {
    @State var controller = initialController()
    var body: some Scene {
        WindowGroup {
            UIViewControllerRepresenting {
                controller
            }
        }
    }
}
