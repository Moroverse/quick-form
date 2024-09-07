// ContentView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

struct ContentView: View {
//    @Bindable var quickForm: PersonForm
//
//    init(quickForm: PersonForm) {
//        self.quickForm = quickForm
//    }

    var body: some View {
//        Form {
//            Text(quickForm.model.givenName)
//                .padding()
//                .onAppear {
//                    quickForm.firstName.value = "Jovanka"
//                }
//            TextField(quickForm.firstName.title, text: $quickForm.firstName.value)
//        }
        EmptyView()
    }
}

//#Preview {
//    @Previewable @State var form = PersonForm(
//        model: .init(
//            givenName: "Marko",
//            familyName: "Grlic",
//            dateOfBirth: Date(),
//            sex: .male
//        )
//    )
//
//    ContentView(quickForm: form)
//}
