// FormToggleField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

/// A SwiftUI view that represents a toggle switch in a form.
///
/// `FormToggleField` is designed to work with ``FormFieldViewModel<Bool>`` to provide
/// a simple interface for boolean inputs. This view is particularly useful for yes/no
/// questions, enabling/disabling features, or any other binary choice in a form.
///
/// ## Features
/// - Displays a toggle switch with a label
/// - Automatically binds to a boolean value in the view model
/// - Supports read-only mode
/// - Uses system font for consistency
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```swift
/// struct UserPreferencesForm: View {
///     @State private var viewModel = FormFieldViewModel(
///         value: false,
///         title: "Receive notifications:",
///         isReadOnly: false
///     )
///
///     var body: some View {
///         Form {
///             FormToggleField(viewModel)
///         }
///     }
/// }
/// ```
///
/// ### Integration with QuickForm Models
///
/// ```swift
/// @QuickForm(Person.self)
/// class PersonEditModel: Validatable {
///     @PropertyEditor(keyPath: \Person.isEstablished)
///     var isEstablished = FormFieldViewModel(
///         type: Bool.self,
///         title: "Established:"
///     )
/// }
///
/// struct PersonEditView: View {
///     @Bindable var model: PersonEditModel
///
///     var body: some View {
///         Form {
///             FormToggleField(model.isEstablished)
///         }
///     }
/// }
/// ```
///
/// ### Handling Toggle Changes
///
/// ```swift
/// struct FeatureToggleView: View {
///     @State private var featureEnabled = FormFieldViewModel(
///         value: false,
///         title: "Enable Experimental Features"
///     )
///
///     var body: some View {
///         Form {
///             FormToggleField(featureEnabled)
///                 .onChange(of: featureEnabled.value) { oldValue, newValue in
///                     if newValue {
///                         // Perform setup when feature is enabled
///                         setupExperimentalFeatures()
///                     } else {
///                         // Clean up when feature is disabled
///                         disableExperimentalFeatures()
///                     }
///                 }
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FormTextField``, ``Validatable``
public struct FormToggleField: View {
    @Bindable private var viewModel: FormFieldViewModel<Bool>
    @State private var hasError: Bool

    /// The body of the toggle field view.
    ///
    /// This view creates a SwiftUI `Toggle` bound to the view model's boolean value.
    /// The toggle's label is set to the title from the view model and uses consistent
    /// system styling to match other form elements.
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Toggle(String(localized: viewModel.title), isOn: $viewModel.value)
                .font(.headline)
                .disabled(viewModel.isReadOnly)
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

    /// Initializes a new `FormToggleField`.
    ///
    /// - Parameter viewModel: The ``FormFieldViewModel`` that manages the state of this toggle field.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a toggle for user preferences
    /// let allowTracking = FormFieldViewModel(
    ///     value: false,
    ///     title: "Allow Usage Tracking",
    ///     isReadOnly: false
    /// )
    ///
    /// // Use the toggle in a form
    /// FormToggleField(allowTracking)
    /// ```
    public init(_ viewModel: FormFieldViewModel<Bool>) {
        self.viewModel = viewModel
        hasError = viewModel.errorMessage != nil
    }
}

#Preview("Default") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: false,
        title: "Enabled",
        isReadOnly: false
    )

    Form {
        FormToggleField(viewModel)
    }
}

#Preview("Read Only") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: true,
        title: "Feature Flag (Read Only)",
        isReadOnly: true
    )

    Form {
        FormToggleField(viewModel)
    }
}

#Preview("Multiple Toggles") {
    @Previewable @State var notifications = FormFieldViewModel(
        value: true,
        title: "Push Notifications"
    )

    @Previewable @State var sounds = FormFieldViewModel(
        value: false,
        title: "Sound Effects"
    )

    @Previewable @State var haptics = FormFieldViewModel(
        value: true,
        title: "Haptic Feedback"
    )

    Form {
        Section("Settings") {
            FormToggleField(notifications)
            FormToggleField(sounds)
            FormToggleField(haptics)
        }
    }
}
