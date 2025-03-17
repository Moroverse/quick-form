// EducationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 20:06 GMT.

import QuickForm
import SwiftUI

struct EducationFormView: View {
    @Bindable private var model: EducationModel
    @Environment(\.dismiss) private var dismiss
    let onDone: (() -> Void)?
    var body: some View {
        Form {
            FormTextField(model.institution)
            FormTextField(model.degree)
            FormTextField(model.fieldOfStudy)
            FormDatePickerField(
                model.startDate,
                range: .distantPast ... Date(),
                displayedComponents: [.date]
            )
            FormDatePickerField(
                model.endDate,
                range: .distantPast ... Date(),
                displayedComponents: [.date]
            )
            FormStepperField(viewModel: model.gpa, range: 5 ... 10, step: 1)

            if case let .failure(error) = model.validationResult {
                Section {
                    Text(error)
                        .listRowBackground(Color.red.opacity(0.5))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    model.state = .committed(model.value)
                    if let onDone {
                        onDone()
                    } else {
                        dismiss()
                    }
                }
                .disabled(!model.isValid)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    model.state = .cancelled
                    if let onDone {
                        onDone()
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }

    init(model: EducationModel, onDone: (() -> Void)? = nil) {
        self.model = model
        self.onDone = onDone
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
