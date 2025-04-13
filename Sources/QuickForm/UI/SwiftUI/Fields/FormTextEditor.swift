// FormTextEditor.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-04 21:17 GMT.

import SwiftUI

/// A SwiftUI view that provides a multi-line text editor in a form.
///
/// `FormTextEditor` is designed to work with ``FormFieldViewModel<String?>`` to provide
/// a multi-line text input field for entering larger text content such as descriptions,
/// notes, or comments. The component intelligently handles optional string values, placeholder
/// text display, and validation feedback.
///
/// ## Features
/// - Displays a multi-line text editor with optional title
/// - Shows placeholder text when value is empty and not focused
/// - Handles optional string values
/// - Supports validation and displays error messages
/// - Adapts to read-only mode
/// - Automatically adjusts minimum height for better usability
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```swift
/// struct NotesForm: View {
///     @State private var notesModel = FormFieldViewModel(
///         value: nil,
///         title: "Notes:",
///         placeholder: "Enter additional notes here..."
///     )
///
///     var body: some View {
///         Form {
///             FormTextEditor(viewModel: notesModel)
///         }
///     }
/// }
/// ```
///
/// ### With Validation
///
/// ```swift
/// @QuickForm(Feedback.self)
/// class FeedbackFormModel: Validatable {
///     @PropertyEditor(keyPath: \Feedback.comments)
///     var comments = FormFieldViewModel<String?>(
///         value: nil,
///         title: "Your Comments:",
///         placeholder: "Please share your thoughts...",
///         validation: .of(.minLength(10, "Please provide at least 10 characters of feedback"))
///     )
/// }
///
/// struct FeedbackFormView: View {
///     @Bindable var model: FeedbackFormModel
///
///     var body: some View {
///         Form {
///             FormTextEditor(viewModel: model.comments)
///                 .validationState(model.comments.validationResult)
///         }
///     }
/// }
/// ```
///
/// ### Read-Only Display
///
/// ```swift
/// struct ReviewDetailsView: View {
///     let reviewText: String
///
///     var body: some View {
///         Form {
///             FormTextEditor(viewModel: FormFieldViewModel(
///                 value: reviewText,
///                 title: "Your Review",
///                 isReadOnly: true
///             ))
///             .padding()
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``FormFieldViewModel``, ``FormTextField``
public struct FormTextEditor: View {
    @FocusState private var isFocused: Bool
    @Bindable private var viewModel: FormFieldViewModel<String?>
    @State private var hasError: Bool

    /// The body of the `FormTextEditor` view.
    ///
    /// This view consists of:
    /// - An optional title label
    /// - A multi-line text editor
    /// - An error message when validation fails
    ///
    /// The text editor shows the placeholder text when the value is empty and
    /// the control is not focused.
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if hasTitle {
                Text(viewModel.title)
                    .font(.headline)
            }
            TextEditor(text: bindableValue)
                .focused($isFocused)
                .foregroundColor(shouldShowPlaceholder ? .secondary : .primary)
                .frame(minHeight: 44)
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
//        .toolbar {
//            ToolbarItemGroup(placement: .keyboard) {
//                Button {
//                    var text = viewModel.value ?? ""
//                    text += "**"
//                    viewModel.value = text
//                } label: {
//                    Image(systemName: "bold")
//                }
//
//                Button {
//                    var text = viewModel.value ?? ""
//                    text += "*"
//                    viewModel.value = text
//                } label: {
//                    Image(systemName: "italic")
//                }
//
//                Button {
//                    var text = viewModel.value ?? ""
//                    text += "`"
//                    viewModel.value = text
//                } label: {
//                    Image(systemName: "doc.text")
//                }
//
//                Spacer()
//
//                Button("Done") {
//                    isFocused = false
//                }
//            }
//        }
    }

    /// Initializes a new `FormTextEditor`.
    ///
    /// - Parameter viewModel: The ``FormFieldViewModel`` that manages the state of this text editor.
    ///   The view model should have a value of type `String?` (optional string).
    ///
    /// ## Example
    ///
    /// ```swift
    /// FormTextEditor(
    ///     viewModel: FormFieldViewModel(
    ///         value: existingNotes,
    ///         title: "Notes",
    ///         placeholder: "Enter notes here..."
    ///     )
    /// )
    /// ```
    public init(viewModel: FormFieldViewModel<String?>) {
        self.viewModel = viewModel
        hasError = viewModel.errorMessage != nil
    }

    /// Checks if the view model has a non-empty title.
    private var hasTitle: Bool {
        let value = String(localized: viewModel.title)
        return value.isEmpty == false
    }

    private var bindableValue: Binding<String> {
        if shouldShowPlaceholder {
            let value = String(localized: viewModel.placeholder ?? "")
            return .constant(value)
        }

        if viewModel.isReadOnly {
            return .constant(viewModel.value ?? "")
        } else {
            return $viewModel.value.unwrapped(defaultValue: "")
        }
    }

    private var shouldShowPlaceholder: Bool {
        if let value = viewModel.value, value.isEmpty == false {
            return false
        }

        let result = isFocused == false

        return result
    }
}

#Preview("Default") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa" as String?,
        title: "Dogs",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}

#Preview("Placeholder") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: String?.none,
        title: "Dogs",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}

#Preview("Not Title") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa" as String?,
        title: "",
        placeholder: "John",
        isReadOnly: false
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}

#Preview("Read only") {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: "Rasa" as String?,
        title: "",
        placeholder: "John",
        isReadOnly: true
    )

    Form {
        FormTextEditor(viewModel: viewModel)
    }
}
