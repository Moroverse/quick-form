# QuickForm

[![Swift](https://img.shields.io/badge/Swift-6.0+-blue.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B%20%7C%20macOS%2014%2B-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.txt)

A declarative Swift framework for building sophisticated form-based user interfaces with automatic data binding, validation, and state management in SwiftUI.

## Overview

QuickForm transforms SwiftUI form development by providing a macro-driven approach that eliminates boilerplate code while ensuring type safety and performance. Using reactive programming patterns and Swift's powerful type system, it creates seamless connections between your data models and user interface.

## Key Features

- **🎯 Declarative Form Definition**: Use Swift macros to define forms with minimal code
- **🔄 Automatic Data Binding**: Bidirectional synchronization between UI and data models
- **✅ Comprehensive Validation**: Built-in and custom validation rules with real-time feedback
- **📝 Rich Field Types**: Text fields, pickers, date selectors, collections, and async data loading
- **🔗 Reactive Relationships**: Build interdependent fields with automatic value propagation
- **🎨 SwiftUI Native**: Seamless integration with SwiftUI's declarative paradigm
- **⚡ Performance Optimized**: Efficient change tracking and minimal re-renders
- **🛡️ Type Safe**: Compile-time guarantees for form field bindings

## Quick Start

### 1. Define Your Data Model

```swift
struct Person {
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
    var dateOfBirth: Date = Date()
    var address: Address = Address()
}
```

### 2. Create Form Model with Automatic Binding

```swift
import QuickForm

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

    @PropertyEditor(keyPath: \Person.email)
    var email = FormFieldViewModel(
        type: String.self,
        title: "Email",
        placeholder: "john@example.com",
        validation: .combined(.notEmpty, .email)
    )

    @PropertyEditor(keyPath: \Person.dateOfBirth)
    var birthday = FormFieldViewModel(
        type: Date.self,
        title: "Date of Birth"
    )
}
```

### 3. Build SwiftUI Interface

```swift
struct PersonEditView: View {
    @StateObject private var model = PersonEditModel()

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    FormTextField(model.firstName)
                    FormTextField(model.lastName)
                    FormTextField(model.email)
                        .keyboardType(.emailAddress)
                }
                
                Section("Details") {
                    FormDatePickerField(model.birthday)
                }
            }
            .navigationTitle("Edit Person")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        if model.validate().isValid {
                            savePerson(model.value) // Access bound data
                        }
                    }
                }
            }
        }
    }
}
```

## Advanced Features

### Field Relationships

Create dynamic forms with interdependent fields:

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
        title: "State"
    )
    
    @PostInit
    func configure() {
        country.onValueChanged { [weak self] newCountry in
            self?.state.allValues = newCountry.states
            self?.state.value = nil
            self?.state.validation = newCountry.requiresState ? .of(.required()) : nil
        }
    }
}
```

### Async Data Loading

Handle remote data sources effortlessly:

```swift
@PropertyEditor(keyPath: \Prescription.medication)
var medication = AsyncPickerFieldViewModel(
    value: nil,
    title: "Medication",
    valuesProvider: { query in
        try await MedicationService.search(query: query)
    },
    queryBuilder: { searchText in
        searchText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
)
```

### Custom Validation

Create domain-specific validation rules:

```swift
struct AgeValidationRule: ValidationRule {
    func validate(_ form: PersonEditModel) -> ValidationResult {
        let age = Calendar.current.dateComponents([.year], 
                                                 from: form.birthday.value, 
                                                 to: Date()).year ?? 0
        return age >= 18 ? .success : .failure("Must be at least 18 years old")
    }
}
```

## Available Field Types

- **FormFieldViewModel**: Basic text input with validation
- **FormattedFieldViewModel**: Input with formatting (currency, phone numbers, etc.)
- **PickerFieldViewModel**: Single selection from a list
- **OptionalPickerFieldViewModel**: Optional single selection
- **MultiPickerFieldViewModel**: Multiple selection
- **AsyncPickerFieldViewModel**: Async data loading with search
- **FormCollectionViewModel**: Dynamic collections with add/remove
- **TokenSetViewModel**: Tag-style input for collections

## Built-in Validation Rules

- `.notEmpty`: Ensures non-empty input
- `.minLength(n)` / `.maxLength(n)`: String length validation
- `.email`: Email format validation
- `.usZipCode` / `.canadianPostalCode`: Postal code validation
- `.required()`: Non-nil validation for optionals
- `.combined(...)`: Combine multiple rules

## Requirements

- **iOS 17.0+** / **macOS 14.0+**
- **Swift 6.0+**
- **Xcode 15.0+**

## Installation

### Swift Package Manager

Add QuickForm to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Moroverse/quick-form.git", from: "0.1.0")
]
```

### Xcode

1. File → Add Package Dependencies
2. Enter: `https://github.com/Moroverse/quick-form.git`
3. Select version and add to target

## Examples

The repository includes comprehensive example applications demonstrating various use cases:

- **Person Editor**: Basic form with validation and field relationships
- **Prescription Form**: Complex medical form with async data loading
- **Application Form**: Multi-section form with collection management

To explore examples:

```bash
# Clone the repository
git clone https://github.com/Moroverse/quick-form.git
cd quick-form

# Generate Xcode projects
make generate

# Open examples
open Examples/Example\ 1/PersonAndMedicationExample.xcodeproj
```

## Documentation

- **[Getting Started Guide][getting-started]**: Step-by-step tutorial
- **[API Reference][api-reference]**: Comprehensive API documentation
- **[Examples][examples]**: Real-world usage patterns

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

QuickForm is available under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.

## Support

- **Documentation**: [QuickForm Docs][Documentation]
- **Issues**: [GitHub Issues](https://github.com/Moroverse/quick-form/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Moroverse/quick-form/discussions)

---

*Built with ❤️ for the Swift community*

[Documentation]: https://moroverse.github.io/quick-form/documentation/quickform/
[getting-started]: https://moroverse.github.io/quick-form/documentation/quickform/gettingstarted
[api-reference]: https://moroverse.github.io/quick-form/documentation/quickform/
[examples]: https://github.com/Moroverse/quick-form/tree/main/Examples
