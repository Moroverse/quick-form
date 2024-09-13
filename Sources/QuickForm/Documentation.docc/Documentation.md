# QuickForm

QuickForm is a Swift package that provides a declarative way to create form-based user interfaces with automatic data binding and validation.

## Overview

QuickForm simplifies the process of creating forms in SwiftUI by providing a set of tools for data binding, validation, and UI generation. It uses property wrappers and custom view models to create a seamless connection between your data model and the UI.

## Installation

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/yourusername/QuickForm.git", from: "1.0.0")
```

## Main Components

### Macros
- ``QuickForm(_:)``
- ``PropertyEditor(keyPath:)``
### Form Filed Models
- ``FormFieldViewModel``
- ``FormattedFieldViewModel``
- ``PickerFieldViewModel``
- ``OptionalPickerFieldViewModel``
- ``FormCollectionViewModel``
### Form Filed Editors
- ``FormTextField``
- ``FormOptionalTextField``
- ``FormFormattedTextField``
- ``FormPickerField``
- ``FormOptionalPickerField``
- ``FormValueUnitField``
- ``FormToggleField``
- ``FormDatePickerField``
- ``FormCollectionSection``
### Validators
- ``Validatable``
- ``ValidationRule``
### Formaters
- ``OptionalFormat``


## Usage Example

Here's a basic example of how to use QuickForm to create a person editing form:

```swift
import SwiftUI
import QuickForm

@QuickForm(Person.self)
class PersonEditModel: Validatable {
@PropertyEditor(keyPath: \Person.givenName)
var firstName = FormFieldViewModel(
value: "",
title: "First Name:",
placeholder: "John",
validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
)

@PropertyEditor(keyPath: \Person.familyName)
var lastName = FormFieldViewModel(
value: "",
title: "Last Name:",
placeholder: "Doe",
validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
)

@PropertyEditor(keyPath: \Person.dateOfBirth)
var birthday = FormFieldViewModel(
    value: Date(),
    title: "Birthday:",
    placeholder: "1980-01-01"
    )
}

struct PersonEditView: View {
@Bindable var quickForm: PersonEditModel

var body: some View {
    Form {
        FormTextField(quickForm.firstName)
        FormTextField(quickForm.lastName)
        FormDatePickerField(quickForm.birthday)
    }
}
}
```

This example creates a form for editing a person's first name, last name, and birthday. The `@QuickForm` macro generates the necessary boilerplate code for managing the form data, while the `@PropertyEditor` property wrapper creates bindings between the form fields and the underlying data model.

## Conclusion

QuickForm provides a powerful set of tools for creating forms in SwiftUI with automatic data binding and validation. By leveraging property wrappers, custom view models, and SwiftUI views, it simplifies the process of building complex forms while maintaining a clean and declarative codebase.
