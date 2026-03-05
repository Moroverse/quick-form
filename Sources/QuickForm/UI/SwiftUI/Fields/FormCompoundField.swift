// FormCompoundField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2026-03-05 GMT.

import Foundation
import SwiftUI

/// A SwiftUI form field for editing a ``CompoundValue`` — a numeric value paired with a selectable unit.
///
/// `FormCompoundField` is the generic counterpart of ``FormValueUnitField``. While
/// `FormValueUnitField` is tied to Foundation's `Measurement<Unit>`, this view works with any
/// type conforming to ``CompoundValue``, enabling custom domain types like `DoseAmount`.
///
/// When the user changes the unit, the numeric value is preserved (no automatic conversion).
///
/// ## Examples
///
/// ### With a Custom CompoundValue
///
/// ```swift
/// struct DoseForm: View {
///     @State private var viewModel = FormFieldViewModel(
///         value: DoseAmount(value: 500, unit: .mg),
///         title: "Dose:"
///     )
///
///     var body: some View {
///         Form {
///             FormCompoundField(viewModel)
///         }
///     }
/// }
/// ```
///
/// ### With Measurement (via retroactive conformance)
///
/// ```swift
/// FormCompoundField(weightViewModel, pickerStyle: .segmented)
/// ```
///
/// - SeeAlso: ``CompoundValue``, ``FormOptionalCompoundField``, ``FormValueUnitField``
public struct FormCompoundField<T: CompoundValue, S: PickerStyle>: View {
    @Bindable private var viewModel: FormFieldViewModel<T>
    @FocusState private var isFocused: Bool
    @State private var hasError: Bool
    private let pickerStyle: S

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(viewModel.title)
                    .font(.headline)
                TextField(String(localized: viewModel.placeholder ?? ""), value: $viewModel.value.value, format: T.ValueType.compoundNumberFormat)
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .disabled(viewModel.isReadOnly)
                    .onSubmit {
                        isFocused = false
                    }
                let binding = Binding(get: {
                    viewModel.value.unit
                }, set: { newUnit, _ in
                    viewModel.value = T(value: viewModel.value.value, unit: newUnit)
                })
                Picker("", selection: binding) {
                    ForEach(T.allUnits) {
                        Text(T.displayString(for: $0))
                            .tag($0)
                    }
                }
                .pickerStyle(pickerStyle)
                .fixedSize()
                .disabled(viewModel.isReadOnly)
            }
            if hasError {
                Text(viewModel.errorMessage ?? "Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: viewModel.validationResult) { _, newValue in
            withAnimation {
                hasError = newValue != .success
            }
        }
    }

    /// Initializes a new `FormCompoundField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` managing the compound value state.
    ///   - pickerStyle: The style for the unit picker. Defaults to `.menu`.
    public init(
        _ viewModel: FormFieldViewModel<T>,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
        hasError = viewModel.errorMessage != nil
        isFocused = false
    }
}

#Preview("Basic - Measurement") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 34, unit: .kilograms),
        title: "Weight"
    )

    Form {
        FormCompoundField(viewModel)
    }
}

#Preview("Segmented - Measurement") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 75, unit: .kilograms),
        title: "Weight"
    )

    Form {
        FormCompoundField(viewModel, pickerStyle: .segmented)
    }
}
