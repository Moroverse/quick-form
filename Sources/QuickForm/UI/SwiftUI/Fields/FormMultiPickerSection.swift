// FormMultiPickerSection.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

import SwiftUI

/// A SwiftUI view that represents a section with multiple selectable options in a form.
///
/// `FormMultiPickerSection` is designed to work with ``MultiPickerFieldViewModel`` to provide
/// a user interface for selecting multiple items from a predefined set of options. It displays
/// each option with a checkbox indicator that shows its selection state.
///
/// This component is particularly useful for forms where users need to select multiple options
/// from a list, such as:
/// - Selecting categories or tags
/// - Choosing multiple features or preferences
/// - Selecting applicable options from a list of choices
///
/// ## Features
/// - Displays a list of selectable items with visual indicators for selection state
/// - Automatically handles adding and removing items from the selection set
/// - Uses standard SwiftUI Form styling for consistent appearance
/// - Properly handles the read-only state from the view model
///
/// ## Examples
///
/// ### Basic Usage with Enum Values
///
/// ```swift
/// enum Category: String, CaseIterable, CustomStringConvertible, Hashable {
///     case work, personal, family, health, finance
///
///     var description: String { rawValue.capitalized }
/// }
///
/// struct TaskCreateView: View {
///     @State private var categories = MultiPickerFieldViewModel(
///         value: [.work],  // Initially selected category
///         allValues: Category.allCases,
///         title: "Categories"
///     )
///
///     var body: some View {
///         Form {
///             FormMultiPickerSection(categories)
///         }
///     }
/// }
/// ```
///
/// ### Integration with Form Models
///
/// ```swift
/// @QuickForm(Task.self)
/// class TaskFormModel: Validatable {
///     @PropertyEditor(keyPath: \Task.categories)
///     var categories = MultiPickerFieldViewModel(
///         value: [.work, .personal],
///         allValues: Category.allCases,
///         title: "Task Categories",
///         validation: .of(.minCount(1, "Please select at least one category"))
///     )
/// }
///
/// struct TaskEditView: View {
///     @Bindable var model: TaskFormModel
///
///     var body: some View {
///         Form {
///             FormMultiPickerSection(model.categories)
///                 .validationState(model.categories.validationResult)
///
///             // Display the current selection count
///             Text("\(model.categories.value.count) categories selected")
///                 .font(.caption)
///         }
///     }
/// }
/// ```
///
/// ### Custom Item Rendering
///
/// To customize the appearance of items beyond the default label, you can use the view modifier pattern:
///
/// ```swift
/// extension FormMultiPickerSection {
///     func customItemStyle<Content: View>(
///         @ViewBuilder content: @escaping (Property, Bool) -> Content
///     ) -> some View {
///         self.modifier(CustomItemStyleModifier(viewModel: viewModel, content: content))
///     }
/// }
///
/// struct ColorSelectionView: View {
///     @Bindable var colorOptions: MultiPickerFieldViewModel<ColorOption>
///
///     var body: some View {
///         FormMultiPickerSection(colorOptions)
///             .customItemStyle { option, isSelected in
///                 HStack {
///                     Circle()
///                         .fill(option.color)
///                         .frame(width: 24, height: 24)
///                     Text(option.name)
///                     Spacer()
///                     if isSelected {
///                         Image(systemName: "checkmark")
///                             .foregroundColor(.accentColor)
///                     }
///                 }
///             }
///     }
/// }
/// ```
///
/// - SeeAlso: ``MultiPickerFieldViewModel``, ``FormMultiPicker``
public struct FormMultiPickerSection<Property: Hashable & CustomStringConvertible>: View {
    @Bindable private var viewModel: MultiPickerFieldViewModel<Property>

    /// The body of the `FormMultiPickerSection` view.
    ///
    /// This view consists of:
    /// - A section with the title from the view model
    /// - A list of buttons representing each available option
    /// - Each button toggles the inclusion of its item in the selection set
    /// - Visual indicators (checkmarks) to show which items are currently selected
    public var body: some View {
        Section {
            ForEach(viewModel.allValues, id: \.hashValue) { item in
                Button {
                    if viewModel.value.contains(item) {
                        viewModel.value.remove(item)
                    } else {
                        viewModel.value.insert(item)
                    }
                } label: {
                    Label(item.description, systemImage: imageNameForItem(item))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isReadOnly)
            }
        } header: {
            Text(viewModel.title)
        }
    }

    /// Creates a new instance of `FormMultiPickerSection`.
    ///
    /// - Parameter viewModel: The ``MultiPickerFieldViewModel`` that manages the multi-selection state.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let dietaryRestrictions = MultiPickerFieldViewModel(
    ///     value: [.glutenFree, .vegan],
    ///     allValues: [.vegetarian, .vegan, .nutFree, .glutenFree, .dairyFree],
    ///     title: "Dietary Restrictions"
    /// )
    ///
    /// FormMultiPickerSection(dietaryRestrictions)
    /// ```
    public init(_ viewModel: MultiPickerFieldViewModel<Property>) {
        self.viewModel = viewModel
    }

    /// Determines the system image name to use for an item based on its selection state.
    ///
    /// - Parameter item: The item to get the image name for.
    /// - Returns: A system image name: "checkmark.circle" for selected items, "circle" for unselected items.
    private func imageNameForItem(_ item: Property) -> String {
        if viewModel.value.contains(item) {
            "checkmark.circle.fill"
        } else {
            "circle"
        }
    }
}

/// Example enum used for the preview.
enum Animal: CustomStringConvertible, Hashable {
    case cat
    case dog
    case bird

    var description: String {
        switch self {
        case .cat: "Cat"
        case .dog: "Dog"
        case .bird: "Bird"
        }
    }
}

#Preview("Basic") {
    @Previewable @State var form = MultiPickerFieldViewModel(
        value: [.cat],
        allValues: [Animal.bird, .cat, .dog],
        title: "Select Animals"
    )

    Form {
        FormMultiPickerSection(form)
    }
}

#Preview("Read-only") {
    @Previewable @State var form = MultiPickerFieldViewModel(
        value: [.cat, .dog],
        allValues: [Animal.bird, .cat, .dog],
        title: "Selected Animals",
        isReadOnly: true
    )

    Form {
        FormMultiPickerSection(form)
    }
}
