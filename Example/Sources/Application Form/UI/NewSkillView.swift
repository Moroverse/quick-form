// NewSkillView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-11 20:31 GMT.

import QuickForm
import SwiftUI

struct NewSkillView: View {
    @Bindable private var model: ExperienceSkillModel
    var body: some View {
        Form {
            FormTextField(model.name)
            FormFormattedTextField(model.level, clearValueMode: .unlessEditing)
        }
        .navigationTitle("New Skill")
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
