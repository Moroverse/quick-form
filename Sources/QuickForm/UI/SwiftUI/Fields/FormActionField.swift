// FormActionField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-06 05:33 GMT.

import Foundation
import SwiftUI

/// A wrapper view that provides dismiss functionality to its content.
///
/// This utility view captures the environment's dismiss action and passes it to its content,
/// allowing nested views to dismiss their presentation context (sheet, popover, etc.).
struct DismissableView<Content: View>: View {
    private let content: (DismissAction) -> Content
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        content(dismiss)
    }

    init(content: @escaping (DismissAction) -> Content) {
        self.content = content
    }
}

/// A form field that presents additional content when tapped, such as a sheet, popover, or navigation destination.
///
/// `FormActionField` displays a field that, when tapped, presents additional content using the specified
/// presentation style. This is useful for complex data entry that requires a dedicated screen or
/// for selecting values from complex interfaces.
///
/// The field supports validation through its associated ``FormFieldViewModel`` and displays
/// error messages when validation fails.
///
/// ## Example Usage
///
/// ### Basic Usage with Navigation
///
/// ```swift
/// struct AddressSelectionView: View {
///     @Bindable var model: PersonFormModel
///
///     var body: some View {
///         Form {
///             FormActionField(model.address, style: .navigation) { dismiss in
///                 AddressPickerView(selectedAddress: $model.address.value) {
///                     dismiss()
///                 }
///             } label: { address in
///                 Text(address?.formattedAddress ?? "Select Address")
///             }
///         }
///     }
/// }
/// ```
///
/// ### Popover Selection for Enumeration Values
///
/// ```swift
/// FormActionField(model.priority, style: .popover) { dismiss in
///     List(Priority.allCases, id: \.self) { priority in
///         Button {
///             model.priority.value = priority
///             dismiss()
///         } label: {
///             HStack {
///                 Text(priority.description)
///                 Spacer()
///                 if model.priority.value == priority {
///                     Image(systemName: "checkmark")
///                 }
///             }
///         }
///     }
///     .presentationDetents([.medium])
/// } label: { priority in
///     Text(priority?.description ?? "Select Priority")
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FieldActionStyleConfiguration``
public struct FormActionField<Property, Label: View, Content: View>: View {
    @Bindable private var viewModel: FormFieldViewModel<Property>
    @State private var hasError: Bool

    private let content: (DismissAction) -> Content
    private let label: (Property) -> Label
    private let presentationStyle: FieldActionStyleConfiguration

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ActionField(
                title: viewModel.title,
                content: {
                    DismissableView(content: content)
                },
                label: {
                    label(viewModel.value)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            )
            .style(presentationStyle)

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

    /// Creates a form field that presents additional content when tapped.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the field's data and validation.
    ///   - style: The presentation style to use (navigation, sheet, popover, etc.).
    ///   - content: A closure that returns the content to display when the field is activated.
    ///     The closure receives a dismiss action that can be called to dismiss the presented content.
    ///   - label: A closure that returns a view to display in the field, representing the current value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormActionField(
    ///     viewModel.dateRange,
    ///     style: .sheet
    /// ) { dismiss in
    ///     DateRangePicker(
    ///         selection: $viewModel.dateRange.value,
    ///         onDone: { dismiss() }
    ///     )
    /// } label: { range in
    ///     if let range {
    ///         Text("\(range.start.formatted(date: .abbreviated, time: .omitted)) - \(range.end.formatted(date: .abbreviated, time: .omitted))")
    ///     } else {
    ///         Text("Select Date Range")
    ///             .foregroundColor(.secondary)
    ///     }
    /// }
    /// ```
    public init(
        _ viewModel: FormFieldViewModel<Property>,
        style: FieldActionStyleConfiguration,
        @ViewBuilder content: @escaping (DismissAction) -> Content,
        @ViewBuilder label: @escaping (Property) -> Label
    ) {
        self.viewModel = viewModel
        self.content = content
        self.label = label
        presentationStyle = style

        hasError = viewModel.errorMessage != nil
    }
}

#Preview("Navigation") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .navigation) { _ in } label: { value in
                Text(verbatim: value)
            }
        }
    }
}

#Preview("Popover") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .popover) { _ in } label: { value in
                Text(verbatim: value)
            }
        }
    }
}

#Preview("Sheet") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormActionField(form, style: .sheet) { _ in } label: { value in
                Text(verbatim: value)
            }
        }
    }
}
