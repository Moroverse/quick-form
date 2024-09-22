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

    @PropertyEditor(keyPath: \Prescription.medication.substance)
    var substance = AsyncPickerFieldViewModel(value: MedicationBuilder.SubstancePart?.none, valuesProvider: SubstanceFetcher.shared.fetchSubstance, queryBuilder: {$0})

    @PropertyEditor(keyPath: \Prescription.medication.route)
    var route = AsyncPickerFieldViewModel(value: MedicationBuilder.MedicationTakeRoutePart?.none, valuesProvider: RouteFetcher.shared.fetchRoute, queryBuilder: { _ in 2 })
}
