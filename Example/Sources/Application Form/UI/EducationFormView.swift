// EducationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 04:49 GMT.

import QuickForm
import SwiftUI

struct EducationFormView: View {
    @Bindable private var model: EducationModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            FormTextField(model.institution)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    model.state = .committed(model.value)
                    dismiss()
                }
                .disabled(!model.isValid)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    model.state = .cancelled
                    dismiss()
                }
            }
        }
    }

    init(model: EducationModel) {
        self.model = model
    }
}

struct EducationFormView_Previews: PreviewProvider {
    struct EducationFormViewWrapper: View {
        @State var model = EducationModel(value: .sample)

        var body: some View {
            EducationFormView(model: model)
        }
    }

    static var previews: some View {
        NavigationStack {
            EducationFormViewWrapper()
        }
    }
}
