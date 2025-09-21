// FormAsyncActionField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 06:14 GMT.

import SwiftUI

/// A form field that performs an asynchronous action when tapped.
///
/// `FormAsyncActionField` displays a field that, when tapped, executes an asynchronous operation
/// provided by the user. This component is ideal for form actions that need to perform network requests,
/// database operations, or other asynchronous tasks.
///
/// The field supports validation through its associated ``FormFieldViewModel`` and displays
/// error messages when validation fails. It also properly handles optional values by displaying
/// a placeholder when the value is nil.
///
/// ## Features
/// - Executes asynchronous actions when tapped
/// - Displays field title and placeholder as appropriate
/// - Shows validation errors
/// - Supports proper handling of optional values
///
/// ## Example Usage
///
/// ### Basic Usage
///
/// ```swift
/// FormAsyncActionField(
///     viewModel: userViewModel.profileImage,
///     action: {
///         // Perform async operation like loading an image
///         await userViewModel.loadProfileImage()
///     }
/// ) { imageData in
///     // Custom display of the image
///     if let uiImage = UIImage(data: imageData) {
///         Image(uiImage: uiImage)
///             .resizable()
///             .scaledToFit()
///             .frame(width: 80, height: 80)
///             .clipShape(Circle())
///     } else {
///         Image(systemName: "person.circle")
///             .resizable()
///             .scaledToFit()
///             .frame(width: 80, height: 80)
///     }
/// }
/// ```
///
/// ### With Progress Tracking
///
/// ```swift
/// @State private var isLoading = false
///
/// FormAsyncActionField(
///     viewModel: accountViewModel.balance,
///     action: {
///         isLoading = true
///         defer { isLoading = false }
///         await accountViewModel.refreshBalance()
///     }
/// ) { balance in
///     HStack {
///         Text(balance.formatted(.currency(code: "USD")))
///         if isLoading {
///             ProgressView()
///                 .scaleEffect(0.7)
///                 .padding(.leading, 5)
///         } else {
///             Image(systemName: "arrow.clockwise")
///                 .foregroundColor(.accentColor)
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``AsyncButton``, ``FormActionField``
public struct FormAsyncActionField<Property, Label: View>: View {
    #if DEBUG
        let inspection = Inspection<Self>()
    #endif
    @Bindable private var viewModel: FormFieldViewModel<Property>
    @State private var hasError: Bool
    @ViewBuilder private var label: (Property) -> Label
    private var action: () async -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            AsyncButton {
                await action()
            } label: {
                HStack(spacing: 10) {
                    if hasTitle {
                        Text(viewModel.title)
                            .accessibilityIdentifier("TITLE")
                            .font(.headline)
                    }

                    if IfOptionalNone() {
                        Text(viewModel.placeholder ?? "")
                            .foregroundStyle(.secondary)
                    } else {
                        label(viewModel.value)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

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
        .registerForInspection(in: self) {
            #if DEBUG
                inspection
            #else
                nil
            #endif
        }
    }

    /// Creates a form field that performs an asynchronous action when tapped.
    ///
    /// - Parameters:
    ///   - viewModel: The ``FormFieldViewModel`` that manages the field's data and validation.
    ///   - action: An asynchronous closure to execute when the field is tapped.
    ///   - label: A view builder that creates a view to display the current value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormAsyncActionField(
    ///     viewModel: addressViewModel.location,
    ///     action: {
    ///         // Request current location
    ///         let location = await locationManager.getCurrentLocation()
    ///         addressViewModel.location.value = location
    ///     }
    /// ) { location in
    ///     HStack {
    ///         Text(location?.formattedAddress ?? "Current Location")
    ///         Image(systemName: "location.circle")
    ///             .foregroundColor(.blue)
    ///     }
    /// }
    /// ```
    public init(
        viewModel: FormFieldViewModel<Property>,
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping (Property) -> Label
    ) {
        self.viewModel = viewModel
        self.label = label
        self.action = action
        hasError = viewModel.errorMessage != nil
    }

    /// Determines if the view model has a non-empty title.
    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    /// Checks if the view model's value is an Optional with a nil wrapped value.
    ///
    /// This is used to determine whether to display the placeholder text.
    func IfOptionalNone() -> Bool {
        if let optional = viewModel.value as? any OptionalProtocol {
            if optional.wrappedValue == nil {
                true
            } else {
                false
            }
        } else {
            false
        }
    }
}

#Preview("Regular") {
    @Previewable @State var form = FormFieldViewModel(value: "Hey, how do you do?", title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormAsyncActionField(
                viewModel: form) {
                    // async action
                } label: { value in
                    Text(value)
                }
        }
    }
}

#Preview("Placeholder") {
    @Previewable @State var form = FormFieldViewModel(value: String?.none, title: "Message", placeholder: "Some text")

    NavigationStack {
        Form {
            FormAsyncActionField(
                viewModel: form) {
                    // async action
                } label: { value in
                    if let value {
                        Text(value)
                    }
                }
        }
    }
}
