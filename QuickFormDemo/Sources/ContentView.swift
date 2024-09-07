// ContentView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

public struct ContentView: View {
    @Bindable var quickForm: QuickForm

    public init(quickForm: QuickForm) {
        self.quickForm = quickForm
    }

    public var body: some View {
        Form {
            Text(quickForm.model.givenName)
                .padding()
                .onAppear {
                    quickForm.firstName.value = "Jovanka"
                }
            TextField(quickForm.firstName.title, text: $quickForm.firstName.value)
        }
    }
}

#Preview {
    @Previewable @State var form = QuickForm(
        model: .init(
            givenName: "Marko",
            familyName: "Grlic",
            dateOfBirth: Date(),
            sex: .male
        )
    )

    ContentView(quickForm: form)
}
