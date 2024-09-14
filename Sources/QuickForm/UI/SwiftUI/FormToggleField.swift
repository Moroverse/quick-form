// FormToggleField.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 18:36 GMT.

import SwiftUI

/// A SwiftUI view that represents a toggle switch in a form.
///
/// `FormToggleField` is designed to work with `FormFieldViewModel<Bool>` to provide
/// a simple interface for boolean inputs. This view is particularly useful for yes/no
/// questions, enabling/disabling features, or any other binary choice in a form.
///
/// ## Features
/// - Displays a toggle switch with a label
/// - Automatically binds to a boolean value in the view model
/// - Supports read-only mode
/// - Uses system font for consistency
///
/// ## Example
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
public struct FormToggleField: View {
    @Bindable private var viewModel: FormFieldViewModel<Bool>

    public var body: some View {
        Toggle(String(localized: viewModel.title), isOn: $viewModel.value)
            .font(.headline)
            .disabled(viewModel.isReadOnly)
    }

    /// Initializes a new `FormToggleField`.
    ///
    /// - Parameter viewModel: The view model that manages the state of this toggle field.
    public init(_ viewModel: FormFieldViewModel<Bool>) {
        self.viewModel = viewModel
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: false,
        title: "Established",
        isReadOnly: false
    )

    Form {
        FormToggleField(viewModel)
    }
}
