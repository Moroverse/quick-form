// AddressView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 06:01 GMT.

import QuickForm
import SwiftUI

struct AddressView: View {
    @Bindable private var model: AddressModel
    var body: some View {
        FormTextField(model.street)
    }

    init(model: AddressModel) {
        self.model = model
    }
}

struct AddressView_Previews: PreviewProvider {
    struct AddressViewWrapper: View {
        @State var model = AddressModel(value: .sample)

        var body: some View {
            AddressView(model: model)
        }
    }

    static var previews: some View {
        NavigationStack {
            Form {
                AddressViewWrapper()
            }
        }
    }
}
