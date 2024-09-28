// PrescriptionEditForm.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

import QuickForm
import SwiftUI

struct PrescriptionEditForm: View {
    @Bindable private var quickForm: PrescriptionEditModel

    var body: some View {
        Form {
            FormMultiPickerSection(quickForm.problems)
            Section("Medication") {
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
        }
    }

    init(quickForm: PrescriptionEditModel) {
        self.quickForm = quickForm
    }
}

struct PrescriptionEditForm_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var form = PrescriptionEditModel(model: fakePrescription)

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
