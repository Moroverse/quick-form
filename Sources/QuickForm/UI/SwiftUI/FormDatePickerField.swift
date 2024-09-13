// FormDatePickerField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI
/// A SwiftUI view that represents a date picker in a form.
///
/// `FormDatePickerField` is designed to work with `FormFieldViewModel<Date>` to provide
/// an interface for selecting dates. This view is particularly useful for inputting
/// birthdays, appointment dates, deadlines, or any other date-related information in a form.
///
/// ## Features
/// - Displays a date picker with a label
/// - Supports customizable date picker styles
/// - Allows specifying which date components to display (date, time, or both)
/// - Automatically binds to a Date value in the view model
/// - Supports read-only mode
///
/// ## Example
///
/// ```swift
/// struct EventForm: View {
///     @State private var viewModel = FormFieldViewModel(
///         value: Date(),
///         title: "Event Date:",
///         isReadOnly: false
///     )
///
///     var body: some View {
///         Form {
///             FormDatePickerField(
///                 viewModel,
///                 displayedComponents: [.date, .hourAndMinute],
///                 style: .graphical
///             )
///         }
///     }
/// }
/// ```
public struct FormDatePickerField<S: DatePickerStyle>: View {
    @Bindable private var viewModel: FormFieldViewModel<Date>
    private let displayedComponents: DatePickerComponents
    private var style: S
    /// Initializes a new `FormDatePickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The view model that manages the state of this date picker field.
    ///   - displayedComponents: The components of the date to display in the picker. Defaults to `[.date]`.
    ///   - style: The style to apply to the date picker. Defaults to `.automatic`.
    public init(
        _ viewModel: FormFieldViewModel<Date>,
        displayedComponents: DatePickerComponents = [.date],
        style: S = DefaultDatePickerStyle.automatic
    ) {
        self.viewModel = viewModel
        self.displayedComponents = displayedComponents
        self.style = style
    }

    public var body: some View {
        DatePicker(String(localized: viewModel.title), selection: $viewModel.value, displayedComponents: displayedComponents)
            .font(.headline)
            .datePickerStyle(style)
            .disabled(viewModel.isReadOnly)
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Date(),
        title: "Birthday",
        isReadOnly: false
    )

    Form {
        FormDatePickerField(viewModel)
    }
}
