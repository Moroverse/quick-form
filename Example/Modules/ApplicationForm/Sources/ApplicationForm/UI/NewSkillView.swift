// NewSkillView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 20:06 GMT.

import QuickForm
import SwiftUI

struct NewSkillView: View {
    @Bindable private var model: ExperienceSkillModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            FormTextField(model.name)
            FormFormattedTextField(model.level, clearValueMode: .unlessEditing)
        }
        .navigationTitle("New Skill")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    model.state = .committed(model.value)
                    dismiss()
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    model.state = .cancelled
                    dismiss()
                }
            }
        }
    }

    init(model: ExperienceSkillModel) {
        self.model = model
    }
}

struct NewSkillView_Previews: PreviewProvider {
    struct NewSkillViewWrapper: View {
        @State var model = ExperienceSkillModel(value: .sample)

        var body: some View {
            NewSkillView(model: model)
        }
    }

    static var previews: some View {
        NavigationStack {
            NewSkillViewWrapper()
        }
    }
}
