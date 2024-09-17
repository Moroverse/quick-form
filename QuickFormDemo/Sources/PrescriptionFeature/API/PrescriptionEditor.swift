//
//  PrescriptionEditor.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//

import UIKit
import SwiftUI

enum PrescriptionEditor {
    @MainActor
    static func prescriptionEditor(for prescription: Prescription) -> UIViewController {
        let viewModel = PrescriptionEditModel(model: prescription)
        let view = PrescriptionEditForm(quickForm: viewModel)
        let wrappedView = Wrapped { view }
        let hostingController = UIHostingController(rootView: wrappedView)
        return hostingController
    }
}
