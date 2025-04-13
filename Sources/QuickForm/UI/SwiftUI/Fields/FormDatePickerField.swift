// FormDatePickerField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

/// A SwiftUI view that represents a date picker in a form.
///
/// `FormDatePickerField` is designed to work with ``FormFieldViewModel<Date>`` to provide
/// an interface for selecting dates. This view is particularly useful for inputting
/// birthdays, appointment dates, deadlines, or any other date-related information in a form.
///
/// ## Features
/// - Displays a date picker with a label
/// - Supports customizable date picker styles (graphical, wheel, compact)
/// - Allows restricting the selectable date range
/// - Allows specifying which date components to display (date, time, or both)
/// - Automatically binds to a Date value in the view model
/// - Supports read-only mode for displaying dates without allowing changes
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```swift
/// struct EventForm: View {
///     @State private var viewModel = FormFieldViewModel(
///         type: Date.self,
///         title: "Event Date:",
///         isReadOnly: false
///     )
///
///     var body: some View {
///         Form {
///             FormDatePickerField(viewModel)
///         }
///     }
/// }
/// ```
///
/// ### With Custom Style and Components
///
/// ```swift
/// // A date and time picker with graphical style
/// FormDatePickerField(
///     viewModel,
///     displayedComponents: [.date, .hourAndMinute],
///     style: .graphical
/// )
///
/// // A date-only picker with wheel style
/// FormDatePickerField(
///     viewModel,
///     displayedComponents: [.date],
///     style: .wheel
/// )
///
/// // A time-only picker with automatic style
/// FormDatePickerField(
///     viewModel,
///     displayedComponents: [.hourAndMinute]
/// )
/// ```
///
/// ### With Date Range Restriction
///
/// ```swift
/// @QuickForm(Event.self)
/// class EventFormModel: Validatable {
///     @PropertyEditor(keyPath: \Event.date)
///     var date = FormFieldViewModel(
///         type: Date.self,
///         title: "Event Date:"
///     )
/// }
///
/// struct EventFormView: View {
///     @Bindable var model: EventFormModel
///
///     var body: some View {
///         Form {
///             // Restrict to dates from today forward only
///             FormDatePickerField(
///                 model.date,
///                 range: Date()...Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
///                 displayedComponents: [.date],
///                 style: .graphical
///             )
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``DefaultDatePickerStyle``
public struct FormDatePickerField<S: DatePickerStyle>: View {
    @Bindable private var viewModel: FormFieldViewModel<Date>
    private let displayedComponents: DatePickerComponents
    private let range: ClosedRange<Date>?
    private var style: S

    /// Initializes a new `FormDatePickerField`.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the state of this date picker field.
    ///   - range: An optional range that restricts which dates can be selected. When `nil` (default),
    ///     any date can be selected.
    ///   - displayedComponents: The components of the date to display in the picker. Defaults to `[.date]`,
    ///     which shows only the calendar date without time. Use `[.date, .hourAndMinute]` to include time.
    ///   - style: The style to apply to the date picker. Defaults to `.automatic`, which lets the system
    ///     choose the most appropriate style for the current context.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a date picker for selecting a future date within the next year
    /// let calendar = Calendar.current
    /// let nextYear = calendar.date(byAdding: .year, value: 1, to: Date())!
    ///
    /// FormDatePickerField(
    ///     viewModel,
    ///     range: Date()...nextYear,
    ///     displayedComponents: [.date],
    ///     style: .graphical
    /// )
    /// ```
    public init(
        _ viewModel: FormFieldViewModel<Date>,
        range: ClosedRange<Date>? = nil,
        displayedComponents: DatePickerComponents = [.date],
        style: S = DefaultDatePickerStyle.automatic
    ) {
        self.viewModel = viewModel
        self.range = range
        self.displayedComponents = displayedComponents
        self.style = style
    }

    /// The body of the `FormDatePickerField` view.
    ///
    /// This view creates a SwiftUI `DatePicker` bound to the view model's value.
    /// The picker is configured with the specified date range (if provided),
    /// displayed components, and styling.
    public var body: some View {
        stylized {
            if let range {
                DatePicker(
                    String(localized: viewModel.title),
                    selection: $viewModel.value,
                    in: range,
                    displayedComponents: displayedComponents
                )
            } else {
                DatePicker(
                    String(localized: viewModel.title),
                    selection: $viewModel.value,
                    displayedComponents: displayedComponents
                )
            }
        }
    }

    /// Applies styling to the date picker content.
    ///
    /// - Parameter content: The content view to be styled.
    /// - Returns: The styled content view.
    func stylized(@ViewBuilder content: @escaping () -> some View) -> some View {
        content()
            .font(.headline)
            .datePickerStyle(style)
            .disabled(viewModel.isReadOnly)
    }
}

#Preview("Default") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Date(),
        title: "Birthday",
        isReadOnly: false
    )

    Form {
        FormDatePickerField(viewModel)
    }
}

#Preview("Range") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: Date(),
        title: "Birthday",
        isReadOnly: false
    )

    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        return calendar.date(from: startComponents)!
            ...
            Date()
    }()

    Form {
        FormDatePickerField(viewModel, range: dateRange)
    }
}
