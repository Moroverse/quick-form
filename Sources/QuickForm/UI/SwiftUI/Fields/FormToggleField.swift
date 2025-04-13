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
/// @QuickForm(UserSettings.self)
/// class SettingsFormModel: Validatable {
///     @PropertyEditor(keyPath: \UserSettings.receiveNotifications)
///     var notifications = FormFieldViewModel(
///         value: false,
///         title: "Receive Notifications"
///     )
///
///     @PropertyEditor(keyPath: \UserSettings.darkMode)
///     var darkMode = FormFieldViewModel(
///         value: false,
///         title: "Dark Mode"
///     )
///
///     @PropertyEditor(keyPath: \UserSettings.locationServices)
///     var locationServices = FormFieldViewModel(
///         value: false,
///         title: "Enable Location Services"
///     )
/// }
///
/// struct SettingsFormView: View {
///     @Bindable var model: SettingsFormModel
///
///     var body: some View {
///         Form {
///             Section("App Settings") {
///                 FormToggleField(model.notifications)
///                 FormToggleField(model.darkMode)
///
///                 // Toggle with reactive dependencies
///                 FormToggleField(model.locationServices)
///
///                 if model.locationServices.value {
///                     // These controls only appear when location services are enabled
///                     FormToggleField(model.backgroundLocation)
///                     FormToggleField(model.preciseLocation)
///                 }
///             }
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

    /// The body of the toggle field view.
    ///
    /// This view creates a SwiftUI `Toggle` bound to the view model's boolean value.
    /// The toggle's label is set to the title from the view model and uses consistent
    /// system styling to match other form elements.
    public var body: some View {
        Toggle(String(localized: viewModel.title), isOn: $viewModel.value)
            .font(.headline)
            .disabled(viewModel.isReadOnly)
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
