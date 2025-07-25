// PrescriptionEditForm.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 12:22 GMT.

import QuickForm
import SwiftUI

extension UnitDose: Identifiable {}

extension UnitDose: AllValues {
    static var allCases: [UnitDose] = [
        .application,
        .capsule,
        .drop,
        .tablet
    ]
}

struct PrescriptionEditForm: View {
    @Bindable private var quickForm: PrescriptionEditModel
    @State private var isPresented: Bool = false
    @FormField(wrappedValue: nil, placeholder: "No substitution") private var message: String?
    var body: some View {
        Form {
            FormMultiPickerSection(quickForm.problems)
            Section("Medication") {
                substanceField()
                routeField()
                dosageFormField()
                strengthField()
                takeField()
                frequencyField()
            }

            Section("Message to Pharmacist") {
                FormActionField(
                    quickForm.messageToPharmacist,
                    style: .navigation
                ) { dismiss in
                    FormTextEditor(viewModel: $message)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button("Done") {
                                    quickForm.messageToPharmacist.value = message
                                    dismiss()
                                }
                            }
                        }
                } label: { _ in
                    FormOptionalTextField(quickForm.messageToPharmacist)
                        .disabled(true)
                }
            }

//            Section {
//                TextEditor(text: .constant(quickForm.info))
//                    .frame(height: 300)
//                    .disabled(true)
//            }
        }
    }

    init(quickForm: PrescriptionEditModel) {
        self.quickForm = quickForm
        message = quickForm.messageToPharmacist.value
    }

    private func substanceField() -> some View {
        FormAsyncPickerField(
            quickForm.medication.substance,
            clearValueMode: .always,
            pickerStyle: .navigation
        ) { substance in
            HStack {
                Text("Substance:")
                    .font(.headline)
                Spacer()
                Text(substance?.substance ?? "No substance selected")
            }
        } pickerContent: { info in
            Text(info.substance)
        }
    }

    private func strengthField() -> some View {
        FormAsyncPickerField(
            quickForm.medication.strength,
            clearValueMode: .always,
            pickerStyle: .navigation,
            allowSearch: false
        ) { strengthPart in
            HStack {
                Text("Strength:")
                    .font(.headline)
                Spacer()
                Text(strengthPart?.strength.rawValue ?? "No strength selected")
            }
        } pickerContent: { strengthPart in
            Text(strengthPart.strength.rawValue)
        }
    }

    private func dosageFormField() -> some View {
        FormAsyncPickerField(
            quickForm.medication.dosageForm,
            clearValueMode: .always,
            allowSearch: false
        ) { dosageFormPart in
            HStack {
                Text("Dosage Form:")
                    .font(.headline)
                Spacer()
                Text(dosageFormPart?.form.rawValue ?? "No dosage form selected")
            }
        } pickerContent: { dosageFormPart in
            Text(dosageFormPart.form.rawValue)
        }
    }

    private func routeField() -> some View {
        FormAsyncPickerField(
            quickForm.medication.route,
            clearValueMode: .always,
            allowSearch: false
        ) { routePart in
            HStack {
                Text("Route:")
                    .font(.headline)
                Spacer()
                Text(routePart?.route.rawValue ?? "No route selected")
            }
        } pickerContent: { routePart in
            Text(routePart.route.rawValue)
        }
    }

    private func originalDispenseField() -> some View {
        NavigationStack {
            FormAsyncPickerField(
                quickForm.dispensePackage.sourceEditor,
                pickerStyle: .inline,
                allowSearch: false
            ) { dispense in
                Text(dispense?.description ?? "No dispense selected")
            } pickerContent: { dispense in
                Text(dispense.description)
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }

    private func takeField() -> some View {
        FormOptionalValueUnitField(
            quickForm.take,
            defaultValue: Measurement<UnitDose>(value: 1, unit: .application)
        )
    }

    private func frequencyField() -> some View {
        MedicationFrequencyPicker(viewModel: quickForm.frequency)
    }

    private func dispenseField() -> some View {
        FormFormattedTextField(quickForm.dispense, clearValueMode: .unlessEditing)
            .trailingAccessories {
                Button {
                    isPresented.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .imageScale(.large)
                }
                .popover(isPresented: $isPresented) {
                    originalDispenseField()
                }
            }
    }
}

struct PrescriptionEditForm_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var form = PrescriptionEditModel(value: fakePrescription)

        var body: some View {
            PrescriptionEditForm(quickForm: form)
        }
    }

    static var previews: some View {
        NavigationStack {
            PreviewWrapper()
        }
    }
}
