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
                FormAsyncPickerField(quickForm.substance, clearValueMode: .always, pickerStyle: .navigation) { substance in
                    HStack {
                        Text("Substance:")
                            .font(.headline)
                        Spacer()
                        Text(substance?.substance ?? "No substance selected")
                    }
                } pickerContent: { info in
                    Text(info.substance)
                }

                FormAsyncPickerField(quickForm.route) { routePart in
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

