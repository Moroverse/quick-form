// PersonEditView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

struct PersonEditView: View {
    @Bindable var quickForm: PersonEditModel
    let delegate: PersonEditorDelegate?

    init(quickForm: PersonEditModel, delegate: PersonEditorDelegate? = nil) {
        self.quickForm = quickForm
        self.delegate = delegate
    }

    @State var info: String = "None"

    var body: some View {
        Form {
            FormTextField(quickForm.firstName)
            FormTextField(quickForm.lastName)
            FormDatePickerField(quickForm.birthday)
            FormPickerField(quickForm.sex)
            FormValueUnitField(quickForm.weight)
            FormFormattedTextField(quickForm.salary)
            FormToggleField(quickForm.isEstablished)
            Section {
                AddressEditView(quickForm: quickForm.address)
            }
            FormCollectionSection(quickForm.careTeam) { personInfo in
                Text(personInfo.name)
            }
            .configure { viewModel in
                viewModel.onInsert {
                    await withCheckedContinuation { continuation in
                        delegate?.didTapOnAddTeamMember? { personInfo in
                            continuation.resume(returning: personInfo)
                        }
                    }
                }
            }

            Button("Deactivate", role: .destructive) {
                delegate?.didTapOnDeactivate?()
            }

            Section {
                TextEditor(text: .constant(info))
                    .frame(height: 300)
                    .disabled(true)
            }
        }
        .navigationTitle(quickForm.personNameComponents.formatted())
        .onChange(of: quickForm.model) {
            info = String(describing: quickForm.model)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var form = PersonEditModel(
            model: Person(
                givenName: "Olivia",
                familyName: "Chen",
                dateOfBirth: Date(timeIntervalSince1970: 707_443_200), // September 3, 1992
                sex: .female,
                phone: "+1 (555) 123-4567",
                salary: 75_000.00,
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
        )

        var body: some View {
            PersonEditView(quickForm: form)
        }
    }

    static var previews: some View {
        NavigationStack {
            PreviewWrapper()
        }
    }
}
