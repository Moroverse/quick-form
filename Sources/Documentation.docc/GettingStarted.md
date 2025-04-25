# Getting Started with QuickForm

Create powerful form-based UIs with minimal code using QuickForm's data binding and validation system.

## Overview

QuickForm is a declarative Swift framework for building sophisticated form UIs with automatic data binding and validation. It streamlines the process of creating form-driven interfaces by handling the complex parts of form management while providing a clean API.

## Key Features

- **Strong Data Binding**: Automatically synchronizes UI components with your data model
- **Built-in Validation**: Comprehensive validation system with predefined and custom rules
- **Diverse Field Types**: Support for text fields, pickers, date selectors, and more
- **Reactive Relationships**: Build interdependent fields with automatic value propagation
- **SwiftUI Integration**: Native SwiftUI components for a seamless development experience

## Installation

Add QuickForm to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/quick-form.git", from: "0..0")
]
```

## Basic Concepts

QuickForm uses several core concepts to create a seamless form development experience:

### Form Models with QuickForm Macro

The `@QuickForm` macro is the starting point for creating a form model:

```swift
import QuickForm

@QuickForm(Person.self)
class PersonEditModel: Validatable {
    // Form fields will go here
}
```

The `@QuickForm` macro connects your form model to your data model (`Person` in this example).

### Field View Models

QuickForm provides specialized view models for different field types:

```swift
@QuickForm(Person.self)
class PersonEditModel: Validatable {
    @PropertyEditor(keyPath: \Person.givenName)
    var firstName = FormFieldViewModel(
        type: String.self,
        title: "First Name:",
        placeholder: "John",
        validation: .combined(.notEmpty, .minLength(2))
    )
    
    @PropertyEditor(keyPath: \Person.dateOfBirth)
    var birthday = FormFieldViewModel(
        type: Date.self,
        title: "Birthday:"
    )
}
```

### Property Binding with PropertyEditor

The `@PropertyEditor` macro creates a binding between your form field and the corresponding property in your data model:

```swift
@PropertyEditor(keyPath: \Person.givenName)
var firstName = FormFieldViewModel(...)
```

### Validation

QuickForm offers built-in validation rules and supports custom validation:

```swift
FormFieldViewModel(
    type: String.self,
    title: "Email:",
    validation: .combined(.notEmpty, .email)
)
```

## Common Field Types

QuickForm provides a variety of field types to handle different data inputs:

### Text Fields

```swift
@PropertyEditor(keyPath: \Person.givenName)
var firstName = FormFieldViewModel(
    type: String.self,
    title: "First Name:",
    placeholder: "John",
    validation: .combined(.notEmpty, .minLength(2))
)
```

### Picker Fields

```swift
@PropertyEditor(keyPath: \Person.sex)
var sex = PickerFieldViewModel(
    type: Person.Sex.self,
    allValues: Person.Sex.allCases,
    title: "Sex:"
)
```

### Optional Picker Fields

```swift
@PropertyEditor(keyPath: \Address.state)
var state = OptionalPickerFieldViewModel(
    type: CountryState?.self,
    allValues: [],
    title: "",
    placeholder: "State"
)
```

### Formatted Fields

```swift
@PropertyEditor(keyPath: \Person.salary)
var salary = FormattedFieldViewModel(
    type: Decimal.self,
    format: .currency(code: "USD"),
    title: "Salary:"
)
```

### Async Picker Fields

```swift
@PropertyEditor(keyPath: \MedicationComponents.strength)
var strength = AsyncPickerFieldViewModel(
    value: MedicationComponents.MedicationStrengthPart?.none,
    validation: .of(.required()),
    valuesProvider: StrengthFetcher.shared.fetchStrength,
    queryBuilder: { _ in 0 }
)
```

## Field Relationships with PostInit

Use `@PostInit` to set up relationships between fields:

```swift
@PostInit
func configure() {
    country.onValueChanged { [weak self] newValue in
        self?.state.allValues = newValue.states
        self?.state.value = nil
        
        // Set conditional validation
        if self?.state.allValues.isEmpty == true {
            self?.state.validation = nil
        } else {
            self?.state.validation = .of(.required())
        }
    }
}
```

## Using Form Fields in SwiftUI

QuickForm provides SwiftUI components that connect to your field view models:

```swift
struct PersonEditView: View {
    @StateObject var model = PersonEditModel()
    
    var body: some View {
        Form {
            FormTextField(model.firstName)
            FormDatePickerField(model.birthday)
            FormPickerField(model.sex)
            
            Button("Save") {
                if model.validate().isValid {
                    savePersonData(model.value)
                }
            }
        }
    }
}
```

## Collection Management

For managing collections of items, use `FormCollectionViewModel` or `TokenSetViewModel`:

```swift
@PropertyEditor(keyPath: \Experience.skills)
var skills = TokenSetViewModel(
    value: [ExperienceSkill](),
    title: "Skills",
    insertionPlaceholder: "Enter a new skill"
) { newString in
    ExperienceSkill(id: UUID(), name: newString, level: 1)
}
```

## Advanced Validation

Create custom validation rules for complex scenarios:

```swift
struct MinValueValidation<T: Comparable>: ValidationRule {
    var minValue: T

    func validate(_ value: T) -> ValidationResult {
        if value < minValue {
            return .failure("Value must be at least \(String(describing: minValue))")
        }
        return .success
    }
}

// Usage
@PropertyEditor(keyPath: \Experience.years)
var years = FormattedFieldViewModel(
    type: Int.self,
    format: .number,
    title: "Years of experience",
    validation: .of(.minValue(4))
)
```

## Form-Wide Validation

Implement the `Validatable` protocol to validate the entire form:

```swift
@QuickForm(Person.self)
class PersonEditModel: Validatable {
    // Fields...
    @PostInit
    func configure() {
        addCustomValidationRule(AgeValidationRule())
    }
}
```

## Next Steps

Now that you understand the basics of QuickForm, explore more advanced features:
??

See the ``FormFieldViewModel``, ``ValidationRule``, and ``Validatable`` documentation for more details.
