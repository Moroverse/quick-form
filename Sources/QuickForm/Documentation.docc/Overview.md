# ``QuickForm``

A declarative Swift framework for building sophisticated form-based user interfaces with automatic data binding, validation, and state management.

## Overview

QuickForm eliminates the complexity of form development in SwiftUI by providing a comprehensive solution for data binding, validation, and UI generation. Using Swift macros and reactive programming patterns, it creates a seamless connection between your data models and user interface while maintaining type safety and performance.

## Key Features

- **Declarative Form Definition**: Use Swift macros to define forms with minimal boilerplate
- **Automatic Data Binding**: Bidirectional synchronization between UI and data models
- **Comprehensive Validation**: Built-in and custom validation rules with real-time feedback
- **Rich Field Types**: Text fields, pickers, date selectors, collections, and async data loading
- **Reactive Relationships**: Build interdependent fields with automatic value propagation
- **SwiftUI Native**: Seamless integration with SwiftUI's declarative UI paradigm

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Moroverse/quick-form.git", from: "0.1.0")
]
```

## Quick Start

Create a form model using the `@QuickForm` macro and define fields with `@PropertyEditor`:

```swift
import SwiftUI
import QuickForm

// Define your data model
struct Person {
    var givenName: String = ""
    var familyName: String = ""
    var dateOfBirth: Date = Date()
    var sex: Sex = .other
    var address: Address = Address()
}

// Create form model with automatic data binding
@QuickForm(Person.self)
class PersonEditModel: Validatable {
    @PropertyEditor(keyPath: \Person.givenName)
    var firstName = FormFieldViewModel(
        type: String.self,
        title: "First Name",
        placeholder: "John",
        validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
    )

    @PropertyEditor(keyPath: \Person.familyName)
    var lastName = FormFieldViewModel(
        type: String.self,
        title: "Last Name",
        placeholder: "Anderson",
        validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
    )

    @PropertyEditor(keyPath: \Person.dateOfBirth)
    var birthday = FormFieldViewModel(
        type: Date.self,
        title: "Birthday"
    )
    
    @PropertyEditor(keyPath: \Person.sex)
    var sex = PickerFieldViewModel(
        type: Person.Sex.self,
        allValues: Person.Sex.allCases,
        title: "Sex"
    )
    
    @PropertyEditor(keyPath: \Person.address)
    var address = AddressEditModel(value: Address())
}

// Build SwiftUI interface
struct PersonEditView: View {
    @StateObject var model = PersonEditModel()

    var body: some View {
        NavigationView {
            Form {
                FormTextField(model.firstName)
                FormTextField(model.lastName)
                FormDatePickerField(model.birthday)
                FormPickerField(model.sex)
                
                Section("Address") {
                    AddressEditView(model: model.address)
                }
            }
            .navigationTitle("Edit Person")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        if model.validate().isValid {
                            savePerson(model.value)
                        }
                    }
                }
            }
        }
    }
}
```

## Advanced Features

### Field Relationships and Dependencies

Set up conditional validation and dynamic field updates:

```swift
@QuickForm(Address.self)
class AddressEditModel: Validatable {
    @PropertyEditor(keyPath: \Address.country)
    var country = PickerFieldViewModel(
        type: Country.self,
        allValues: Country.allCases,
        title: "Country"
    )
    
    @PropertyEditor(keyPath: \Address.state)
    var state = OptionalPickerFieldViewModel(
        type: CountryState?.self,
        allValues: [],
        title: "State",
        placeholder: "Select State"
    )
    
    @PostInit
    func configure() {
        // Update state options when country changes
        country.onValueChanged { [weak self] newCountry in
            self?.state.allValues = newCountry.states
            self?.state.value = nil
            
            // Conditional validation based on country
            if self?.state.allValues.isEmpty == true {
                self?.state.validation = nil
            } else {
                self?.state.validation = .of(.required())
            }
        }
    }
}
```

### Async Data Loading

Handle remote data sources with built-in loading states:

```swift
@PropertyEditor(keyPath: \Prescription.medication)
var medication = AsyncPickerFieldViewModel(
    value: nil,
    title: "Medication",
    valuesProvider: { query in
        try await MedicationService.search(query: query)
    },
    queryBuilder: { searchText in
        searchText ?? ""
    }
)
```

This comprehensive example demonstrates QuickForm's power in creating sophisticated, data-driven forms with minimal code while maintaining excellent performance and user experience.

## Topics

### Essentials
- <doc:GettingStarted>

### Macros
- ``QuickForm(_:)``
- ``PropertyEditor(keyPath:)``
- ``PostInit()``
- ``OnInit()``
- ``Dependency()``

### Form Field Models
- ``FormFieldViewModel``
- ``FormattedFieldViewModel``
- ``PickerFieldViewModel``
- ``OptionalPickerFieldViewModel``
- ``MultiPickerFieldViewModel``
- ``FormCollectionViewModel``
- ``AsyncPickerFieldViewModel``
- ``TokenSetViewModel``
- ``ValueEditorTransformer``
- ``ModelTransformer``

### Form Field Editors
- ``FormTextField``
- ``FormOptionalTextField``
- ``FormFormattedTextField``
- ``FormPickerField``
- ``FormOptionalPickerField``
- ``FormValueUnitField``
- ``FormValueDimensionField``
- ``FormOptionalValueUnitField``
- ``FormToggleField``
- ``FormDatePickerField``
- ``FormCollectionSection``
- ``FormMultiPickerSection``
- ``FormAsyncPickerField``
- ``FormSecureTextField``
- ``FormTextEditor``
- ``FormTokenSetField``
- ``FormStepperField``

### Validators
- ``Validatable``
- ``ValidationRule``
- ``ValidationResult``
- ``MaxLengthRule``
- ``MinLengthRule``
- ``NotEmptyRule``
- ``RequiredRule``
- ``AnyValidationRule``

### Formatters
- ``OptionalFormat``
- ``PlainStringFormat``
- ``AutoMask``
- ``ClearValueMode``

