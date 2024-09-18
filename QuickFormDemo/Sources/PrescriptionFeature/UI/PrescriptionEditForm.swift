//
//  PrescriptionEditForm.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//

import QuickForm
import SwiftUI

struct PrescriptionEditForm: View {
    @Bindable private var quickForm: PrescriptionEditModel

    var body: some View {
        Form {
            FormMultiPickerSection(quickForm.problems)
            Section("Medication") {
                FormAsyncPickerField(quickForm.medicationName.original, clearValueMode: .always, pickerStyle: .navigation) { _ in
                    FormTextField(quickForm.medicationName.new)
                } pickerContent: { info in
                    Text(info.name)
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

