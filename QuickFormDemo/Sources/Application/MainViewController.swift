//
//  MainViewController.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 16.9.24..
//

import UIKit

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


class MainViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    private var didDismiss: ((PersonInfo?) -> Void)?
    private var presentedForm: UIViewController?

    private lazy var showFormButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Form", for: .normal)
        button.addTarget(self, action: #selector(showFormTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(showFormButton)

        NSLayoutConstraint.activate([
            showFormButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showFormButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func showFormTapped() {
        let delegate = PersonEditorDelegate {[weak self] in
            let warning = WarningOptions.warning()
            self?.presentedForm?.present(warning, animated: true)
        } didTapOnAddTeamMember: { [weak self] completion in
            let delegate = PersonSearchViewDelegate { personInfo in
                completion(personInfo)
                self?.presentedForm?.dismiss(animated: true)
            }
            let personSearch = PersonSearch.personSearch(delegate: delegate)
            self?.didDismiss = completion
            self?.presentedForm?.present(personSearch, animated: true)
        }

        let editor = PersonEditor.personEditor(for: fakePerson, delegate: delegate)
        editor.modalPresentationStyle = .pageSheet
        present(editor, animated: true)
        presentedForm = editor
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        didDismiss?(nil)
    }
}
