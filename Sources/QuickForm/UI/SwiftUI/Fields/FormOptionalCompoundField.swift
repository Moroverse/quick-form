// FormOptionalCompoundField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2026-03-05 GMT.

import Foundation
import SwiftUI

/// A SwiftUI form field for editing an optional ``CompoundValue``.
///
/// `FormOptionalCompoundField` is the generic counterpart of ``FormOptionalValueUnitField``.
/// It works with any type conforming to ``CompoundValue``, using a `defaultValue` to handle the
/// `nil` case — providing both a fallback numeric value and unit.
///
/// ## Examples
///
/// ### Optional Dose with Default
///
/// ```swift
/// struct DosageForm: View {
///     @State private var viewModel = FormFieldViewModel<DoseAmount?>(
///         value: nil,
///         title: "Dose:",
///         placeholder: "Enter dose"
///     )
///
///     var body: some View {
///         Form {
///             FormOptionalCompoundField(
///                 viewModel,
///                 defaultValue: DoseAmount(value: 0, unit: .mg)
///             )
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``CompoundValue``, ``FormCompoundField``, ``FormOptionalValueUnitField``
public struct FormOptionalCompoundField<T: CompoundValue, S: PickerStyle>: View {
    @Bindable private var viewModel: FormFieldViewModel<T?>
    @FocusState private var isFocused: Bool
    @State private var hasError: Bool
    private let pickerStyle: S
    private let defaultValue: T

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(viewModel.title)
                    .font(.headline)
                TextField(String(localized: viewModel.placeholder ?? ""), value: $viewModel.value.unwrapped(defaultValue: defaultValue).value, format: T.ValueType.compoundNumberFormat)
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .disabled(viewModel.isReadOnly)
                    .onSubmit {
                        isFocused = false
                    }
                let binding = Binding(get: {
                    viewModel.value?.unit ?? defaultValue.unit
                }, set: { newUnit, _ in
                    viewModel.value = T(value: viewModel.value?.value ?? defaultValue.value, unit: newUnit)
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

    /// Initializes a new `FormOptionalCompoundField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` managing the optional compound value.
    ///   - defaultValue: The value to use when the binding is `nil`.
    ///   - pickerStyle: The style for the unit picker. Defaults to `.menu`.
    public init(
        _ viewModel: FormFieldViewModel<T?>,
        defaultValue: T,
        pickerStyle: S = .menu
    ) {
        self.viewModel = viewModel
        self.defaultValue = defaultValue
        self.pickerStyle = pickerStyle
        hasError = viewModel.errorMessage != nil
        isFocused = false
    }
}

#Preview("Basic - Optional Measurement") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>?.none,
        title: "Weight"
    )

    Form {
        FormOptionalCompoundField(viewModel, defaultValue: Measurement<UnitMass>(value: 0, unit: .kilograms))
    }
}

#Preview("With Value - Measurement") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Measurement<UnitMass>?.some(.init(value: 75, unit: .kilograms)),
        title: "Weight"
    )

    Form {
        FormOptionalCompoundField(viewModel, defaultValue: Measurement<UnitMass>(value: 0, unit: .kilograms))
    }
}
