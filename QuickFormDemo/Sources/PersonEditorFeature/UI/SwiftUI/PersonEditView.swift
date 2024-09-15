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
    @State private var showAlert = false

    var body: some View {
        Form {
            HStack(alignment: .center) {
                FormAsyncPickerField(quickForm.avatar, clearValueMode: .always) { selection in
                    if let selection {
                        Image(selection.imageName)
                            .resizable()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                    } else {
                        VStack {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 88, height: 88)
                            Spacer()
                            Text("No Person Avatar Selected")
                        }
                    }
                } pickerContent: { avatar in
                    HStack {
                        Image(avatar.imageName)
                            .resizable()
                            .frame(width: 88, height: 88)
                        Text(avatar.id.formatted())
                    }
                }
                Divider()
                VStack {
                    FormTextField(quickForm.firstName, autocapitalizationType: .words)
                        .frame(minHeight: 44)

                    Divider()
                    FormTextField(quickForm.lastName, autocapitalizationType: .words)
                        .frame(minHeight: 44)
                }
            }

            FormDatePickerField(quickForm.birthday, style: .compact)
            FormPickerField(quickForm.sex)
            FormValueUnitField(quickForm.weight)
            FormFormattedTextField(quickForm.salary)
            FormToggleField(quickForm.isEstablished)
            FormFormattedTextField(quickForm.phone)
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

            Section("Security") {
                FormSecureTextField(quickForm.password)
                FormSecureTextField(quickForm.passwordReentry)
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
        .toolbar {
            if !quickForm.isValid {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        showAlert.toggle()
                    }, label: {
                        Image(systemName: "exclamationmark.triangle")
                    })
                    .foregroundStyle(.red)
                    .popover(isPresented: $showAlert) {
                        Text(quickForm.errorMessage ?? "Person is not valid")
                            .foregroundStyle(.red)
                            .padding()
                    }
                }
            }
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
