// PrescriptionEditor.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

import SwiftUI
import UIKit

enum PrescriptionEditor {
    @MainActor
    static func prescriptionEditor(for prescription: PrescriptionComponents) -> UIViewController {
        let viewModel = PrescriptionEditModel(value: prescription)
        let view = PrescriptionEditForm(quickForm: viewModel)
        let wrappedView = Wrapped { view }
        let hostingController = UIHostingController(rootView: wrappedView)
        return hostingController
    }
}
