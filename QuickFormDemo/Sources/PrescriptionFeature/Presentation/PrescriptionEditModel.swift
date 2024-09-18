//
//  PresriptionForm.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//

@preconcurrency import QuickForm
import Observation
import Foundation

@QuickForm(Prescription.self)
final class PrescriptionEditModel: Validatable {

    @PropertyEditor(keyPath: \Prescription.assessments)
    var problems = MultiPickerFieldViewModel(value: [], allValues: [
        Assessment(name: "BCC", id: 1),
        Assessment(name: "SCC", id: 2)
    ], title: "Assessments")

    @PropertyEditor(keyPath: \Prescription.medication.name)
    var medicationName = ModelTransformer(
        original: AsyncPickerFieldViewModel(value: MedicationInfo?.none, valuesProvider: MedicationFetcher.shared.fetchMedication, queryBuilder: {$0}),
        new: FormFieldViewModel(value: "", title: "Name:", placeholder: "Aspirin", isReadOnly: true),
        mapFrom: { $0?.name ?? "" },
        mapTo: { _ in MedicationInfo?.none }
    )
}
