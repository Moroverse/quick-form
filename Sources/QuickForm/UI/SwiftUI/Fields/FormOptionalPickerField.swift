// FormOptionalPickerField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 19:25 GMT.

import SwiftUI

/// A SwiftUI view that represents an optional picker field in a form.
///
/// `FormOptionalPickerField` is designed to work with optional values in forms where the user
/// can select from a list of options or choose none. It provides a picker interface that can
/// have no selection (representing `nil`) or a selected value from the provided options.
///
/// This view is typically used in conjunction with an ``OptionalPickerFieldViewModel`` to manage its state
/// and integrates seamlessly with SwiftUI forms.
///
/// ## Features
/// - Handles optional values of any `Hashable` and `CustomStringConvertible` type
/// - Displays a title for the field
/// - Supports customizable picker styles (menu, wheel, segmented, etc.)
/// - Shows validation error messages
/// - Supports read-only mode
/// - Offers configurable clear button functionality
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```swift
/// enum Department: String, CaseIterable, CustomStringConvertible {
///     case sales, engineering, marketing, none
///     var description: String { rawValue.capitalized }
/// }
///
/// struct EmployeeForm: View {
///     @State private var viewModel = OptionalPickerFieldViewModel<Department>(
///         value: nil, // Initially no selection
///         allValues: Department.allCases,
///         title: "Department:",
///         validation: .of(.required("Please select a department"))
///     )
///
///     var body: some View {
///         Form {
///             FormOptionalPickerField(viewModel)
///         }
///     }
/// }
/// ```
///
/// ### Different Picker Styles
///
/// ```swift
/// // Menu style picker (default)
/// FormOptionalPickerField(viewModel)
///
/// // Wheel style picker
/// FormOptionalPickerField(viewModel, pickerStyle: .wheel)
///
/// // Segmented style picker (good for few options)
/// FormOptionalPickerField(viewModel, pickerStyle: .segmented)
/// ```
///
/// ### With Clear Button
///
/// ```swift
/// // Always show clear button when a value is selected
/// FormOptionalPickerField(
///     viewModel,
///     clearValueMode: .always
/// )
///
/// // For forms with mixed field styles, consistent clear button behavior:
/// VStack {
///     FormTextField(nameField, clearValueMode: .always)
///     FormOptionalPickerField(departmentField, clearValueMode: .always)
///     FormDatePickerField(startDateField)
/// }
/// ```
///
/// ### With Validation and Form Integration
///
/// ```swift
/// @QuickForm(Employee.self)
/// class EmployeeFormModel: Validatable {
///     @PropertyEditor(keyPath: \Employee.department)
///     var department = OptionalPickerFieldViewModel(
///         value: nil,
///         allValues: Department.allCases,
///         title: "Department:",
///         validation: .of(.required("Department is required"))
///     )
///
///     @PropertyEditor(keyPath: \Employee.position)
///     var position = OptionalPickerFieldViewModel<Position>(
///         value: nil,
///         allValues: [],  // Will be populated based on department
///         title: "Position:",
///         placeholder: "Select position"
///     )
/// }
///
/// struct EmployeeFormView: View {
///     @Bindable var model: EmployeeFormModel
///
///     var body: some View {
///         Form {
///             Section("Employment Information") {
///                 FormOptionalPickerField(model.department)
///                     .validationState(model.department.validationResult)
///
///                 if model.department.value != nil {
///                     FormOptionalPickerField(
///                         model.position,
///                         clearValueMode: .always
///                     )
///                 }
///             }
///         }
///         .onAppear {
///             // Update available positions when department changes
///             model.department.onValueChanged { department in
///                 if let dept = department {
///                     model.position.allValues = getPositionsFor(department: dept)
///                     model.position.value = nil
///                 } else {
///                     model.position.allValues = []
///                     model.position.value = nil
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``OptionalPickerFieldViewModel``, ``FormPickerField``, ``ClearValueMode``, ``ValidationResult``
public struct FormOptionalPickerField<Property: Hashable & CustomStringConvertible, S: PickerStyle>: View {
    @Bindable private var viewModel: OptionalPickerFieldViewModel<Property>
    @State private var hasError: Bool
    private let pickerStyle: S
    let clearValueMode: ClearValueMode

    /// Initializes a new `FormOptionalPickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``OptionalPickerFieldViewModel`` that manages the state of this picker field.
    ///   - pickerStyle: The style to apply to the picker. Defaults to `.menu`.
    ///   - clearValueMode: Controls when the clear button appears. Defaults to `.never`.
    ///     - `.never`: Never show a clear button
    ///     - `.always`: Always show a clear button when a value is selected
    ///     - `.whileEditing`: Show a clear button only when the field is being edited
    ///     - `.unlessEditing`: Show a clear button except when the field is being edited
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Basic usage with menu style (default)
    /// FormOptionalPickerField(departmentViewModel)
    ///
    /// // Customized with wheel style and clear button
    /// FormOptionalPickerField(
    ///     categoryViewModel,
    ///     pickerStyle: .wheel,
    ///     clearValueMode: .always
    /// )
    /// ```
    public init(
        _ viewModel: OptionalPickerFieldViewModel<Property>,
        pickerStyle: S = .menu,
        clearValueMode: ClearValueMode = .never
    ) {
        self.viewModel = viewModel
        self.pickerStyle = pickerStyle
        self.clearValueMode = clearValueMode
        hasError = viewModel.errorMessage != nil
    }

    /// The body of the `FormOptionalPickerField` view.
    ///
    /// This view consists of:
    /// - A picker with an optional "None" choice and all provided values
    /// - An optional clear button (depending on `clearValueMode`)
    /// - An error message (if validation fails)
    ///
    /// The picker's style can be customized through the `pickerStyle` parameter in the initializer.
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Picker(selection: $viewModel.value) {
                    Text("None")
                        .tag(Property?.none)
                    ForEach(viewModel.allValues, id: \.self) { itemCase in
                        Text(itemCase.description)
                            .tag(Optional(itemCase))
                    }
                } label: {
                    if hasTitle {
                        Text(viewModel.title)
                            .font(.headline)
                    } else {
                        if shouldDisplayPlaceholder {
                            Text(viewModel.placeholder ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .pickerStyle(pickerStyle)
                .disabled(viewModel.isReadOnly)
                if shouldDisplayClearButton {
                    Button {
                        viewModel.value = nil
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(.borderless)
                }
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

    /// Determines whether to display the placeholder text.
    ///
    /// The placeholder is shown when:
    /// - The current value is `nil`
    /// - A placeholder text is provided in the view model
    private var shouldDisplayPlaceholder: Bool {
        if case .none = viewModel.value {
            hasPlaceholder
        } else {
            false
        }
    }

    /// Determines whether to display the clear button.
    ///
    /// The clear button visibility is controlled by:
    /// - The `clearValueMode` parameter
    /// - Whether a value is currently selected
    /// - The `isReadOnly` property of the view model
    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        switch clearValueMode {
        case .never:
            return false

        default:
            return viewModel.value != nil
        }
    }

    /// Checks if the view model has a non-empty title.
    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    /// Checks if the view model has a non-empty placeholder.
    private var hasPlaceholder: Bool {
        let value = String(localized: viewModel.placeholder ?? "")
        return value.isEmpty == false
    }
}

#Preview("Basic") {
    @Previewable @State var viewModel = OptionalPickerFieldViewModel<String>(
        value: nil,
        allValues: ["Red", "Green", "Blue"],
        title: "Color"
    )

    Form {
        FormOptionalPickerField(viewModel)
    }
}

#Preview("With Selection") {
    @Previewable @State var viewModel = OptionalPickerFieldViewModel<String>(
        value: "Green",
        allValues: ["Red", "Green", "Blue"],
        title: "Color"
    )

    Form {
        FormOptionalPickerField(viewModel)
    }
}

#Preview("With Clear Button") {
    @Previewable @State var viewModel = OptionalPickerFieldViewModel<String>(
        value: "Green",
        allValues: ["Red", "Green", "Blue"],
        title: "Color"
    )

    Form {
        FormOptionalPickerField(viewModel, clearValueMode: .always)
    }
}

#Preview("With Validation Error") {
    @Previewable @State var viewModel = OptionalPickerFieldViewModel<String>(
        value: nil,
        allValues: ["Red", "Green", "Blue"],
        title: "Color",
        validation: .of(.required())
    )

    Form {
        FormOptionalPickerField(viewModel)
            .onAppear {
                _ = viewModel.validate()
            }
    }
}
