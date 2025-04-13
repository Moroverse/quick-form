// FormTokenSetField.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 20:26 GMT.

import SwiftUI

/// A SwiftUI view that displays a collection of tokens that can be selected, removed, and added.
///
/// `FormTokenSetField` is designed to work with ``TokenSetViewModel`` to provide
/// an interface for managing a set of tokens (tags) in a form. This component is particularly
/// useful for representing collections of items like tags, categories, skills, or any other
/// data that is naturally represented as a group of labeled items.
///
/// ## Features
/// - Displays tokens in a grid layout with automatic wrapping
/// - Supports token selection with visual feedback
/// - Allows token removal with dismissible buttons
/// - Optionally includes an input field for adding new tokens
/// - Shows an optional title/label
/// - Customizable through the view model properties
///
/// ## Examples
///
/// ### Basic Usage with String Tokens
///
/// ```swift
/// struct Tag: Identifiable, CustomStringConvertible {
///     let id = UUID()
///     let description: String
/// }
///
/// struct TagsForm: View {
///     @State private var viewModel = TokenSetViewModel(
///         value: [
///             Tag(description: "SwiftUI"),
///             Tag(description: "iOS"),
///             Tag(description: "macOS")
///         ],
///         title: "Technologies:",
///         insertionPlaceholder: "Add new tag...",
///         insertionMapper: { Tag(description: $0) }
///     )
///
///     var body: some View {
///         Form {
///             FormTokenSetField(viewModel: viewModel)
///         }
///     }
/// }
/// ```
///
/// ### With Selection Handling
///
/// ```swift
/// struct SkillsSelector: View {
///     @Bindable var skillsViewModel: TokenSetViewModel<Skill>
///
///     var body: some View {
///         FormTokenSetField(viewModel: skillsViewModel)
///             .onChange(of: skillsViewModel.selection) { oldValue, newValue in
///                 if let selectedID = newValue {
///                     showDetailsForSkill(id: selectedID)
///                 }
///             }
///     }
///
///     private func showDetailsForSkill(id: Skill.ID) {
///         guard let skill = skillsViewModel.value.first(where: { $0.id == id }) else { return }
///         // Show detail view or perform action with selected skill
///     }
/// }
/// ```
///
/// ### Read-Only Token Display
///
/// ```swift
/// // Create a token set that doesn't allow adding or removing tokens
/// let tagsViewModel = TokenSetViewModel(
///     value: existingTags,
///     title: "Tags",
///     canRemove: { _ in false },  // Prevent removal
///     canInsert: false            // Disable adding new tags
/// )
///
/// FormTokenSetField(viewModel: tagsViewModel)
/// ```
///
/// ### With Custom Token Types
///
/// ```swift
/// struct Category: Identifiable, CustomStringConvertible {
///     let id: Int
///     let name: String
///     let color: Color
///
///     var description: String { name }
/// }
///
/// // Use with custom token type
/// let categoriesViewModel = TokenSetViewModel(
///     value: [
///         Category(id: 1, name: "Work", color: .blue),
///         Category(id: 2, name: "Personal", color: .green),
///         Category(id: 3, name: "Urgent", color: .red)
///     ],
///     title: "Categories"
/// )
///
/// // In your view
/// FormTokenSetField(viewModel: categoriesViewModel)
/// ```
///
/// - SeeAlso: ``TokenSetViewModel``, ``DismissibleButton``
public struct FormTokenSetField<Property: Identifiable & CustomStringConvertible>: View {
    @Bindable private var viewModel: TokenSetViewModel<Property>
    let columns = [GridItem(.adaptive(minimum: 100))]

    @State var newTag: String = ""

    /// The body of the `FormTokenSetField` view.
    ///
    /// This view consists of:
    /// - An optional title with a divider
    /// - A grid of tokens presented as buttons that can be selected
    /// - Optional dismiss buttons on tokens that can be removed
    /// - An optional text field for adding new tokens
    public var body: some View {
        HStack(alignment: .center) {
            if let title = viewModel.title {
                Text(title)
                    .font(.headline)

                Divider()
            }

            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                    ForEach(viewModel.value) { code in
                        DismissibleButton(dismissible: viewModel.canDelete(code)) {
                            viewModel.selection = code.id
                        } label: {
                            Text(code.description)
                        }
                        .onDismiss { [id = code.id] in
                            withAnimation {
                                viewModel.remove(id: id)
                            }
                        }
                        .padding(.vertical, 1)
                        .buttonBorderShape(.capsule)
                        .modifier(ButtonToggleStyle(isSelected: code.id == viewModel.selection))
                    }
                    if viewModel.canInsert {
                        TextField(
                            "",
                            text: $newTag,
                            prompt: Text(String(localized: viewModel.insertionPlaceholder ?? ""))
                        )
                        .textFieldStyle(.plain)
                        .onSubmit {
                            withAnimation {
                                if viewModel.insert(newTag) {
                                    newTag = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /// Initializes a new `FormTokenSetField`.
    ///
    /// - Parameter viewModel: The ``TokenSetViewModel`` that manages the state of this token field.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a view model for managing tags
    /// let tagsViewModel = TokenSetViewModel(
    ///     value: initialTags,
    ///     title: "Tags",
    ///     insertionPlaceholder: "Add new tag"
    /// ) { tagText in
    ///     // Convert text input to a tag
    ///     return Tag(description: tagText)
    /// }
    ///
    /// // Use the view model with FormTokenSetField
    /// FormTokenSetField(viewModel: tagsViewModel)
    /// ```
    public init(viewModel: TokenSetViewModel<Property>) {
        self.viewModel = viewModel
    }
}

/// A view modifier that applies different button styles based on selection state.
///
/// This modifier applies a prominent style to selected buttons and a standard bordered
/// style to unselected buttons.
struct ButtonToggleStyle: ViewModifier {
    /// Whether the button is in a selected state.
    let isSelected: Bool

    /// Applies the appropriate button style based on the selection state.
    func body(content: Content) -> some View {
        if isSelected {
            content
                .buttonStyle(.borderedProminent)
        } else {
            content
                .buttonStyle(.bordered)
        }
    }
}

/// A simple token implementation for previews and examples.
struct Token: CustomStringConvertible, Identifiable {
    var id: String { description }
    var description: String
}

#Preview("Empty") {
    @Previewable @State var model = TokenSetViewModel(
        value: [Token](),
        title: "Tokens",
        insertionPlaceholder: "Type here...",
        insertionMapper: { Token(description: $0) }
    )
    NavigationStack {
        Form {
            FormTokenSetField(viewModel: model)
        }
    }
}

#Preview("With Items") {
    @Previewable @State var model = TokenSetViewModel(
        value: [
            Token(description: "Swift"),
            Token(description: "SwiftUI"),
            Token(description: "iOS"),
            Token(description: "macOS")
        ],
        title: "Technologies",
        insertionPlaceholder: "Add technology...",
        insertionMapper: { Token(description: $0) }
    )
    NavigationStack {
        Form {
            FormTokenSetField(viewModel: model)
        }
    }
}

#Preview("Read-Only") {
    @Previewable @State var model = TokenSetViewModel(
        value: [
            Token(description: "Urgent"),
            Token(description: "Bug"),
            Token(description: "Customer")
        ],
        title: "Tags",
        insertionPlaceholder: nil
    )
    NavigationStack {
        Form {
            FormTokenSetField(viewModel: model)
        }
    }
}
