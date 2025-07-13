# Getting Started with QuickForm

Build robust, type-safe forms with automatic data binding and validation using QuickForm's declarative API.

## Overview

QuickForm transforms SwiftUI form development by providing a macro-driven approach to creating sophisticated form interfaces. By leveraging Swift's type system and reactive programming patterns, it eliminates boilerplate code while ensuring compile-time safety and runtime performance.

## Core Architecture

QuickForm is built around several key components that work together seamlessly:

- **Form Models**: Classes that define the structure and behavior of your forms
- **Field View Models**: Specialized components for different input types
- **Automatic Data Binding**: Bidirectional synchronization between forms and data models
- **Validation System**: Declarative rules with real-time feedback
- **SwiftUI Integration**: Native components that feel natural in SwiftUI

## Step 1: Define Your Data Model

Start with a standard Swift struct or class that represents your data:

```swift
struct Person {
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
    var dateOfBirth: Date = Date()
    var sex: Sex = .other
    var isEstablished: Bool = false
    var address: Address = Address()
}

enum Sex: String, CaseIterable {
    case male, female, other
}

struct Address {
    var line1: String = ""
    var line2: String? = nil
    var city: String = ""
    var zipCode: String = ""
    var country: Country = .unitedStates
    var state: CountryState? = nil
}
```

## Step 2: Create the Form Model

Use the `@QuickForm` macro to create a form model that automatically binds to your data:

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

    @PropertyEditor(keyPath: \Person.sex)
    var sex = PickerFieldViewModel(
        type: Person.Sex.self,
        allValues: Person.Sex.allCases,
        title: "Sex"
    )

    @PropertyEditor(keyPath: \Person.isEstablished)
    var isEstablished = FormFieldViewModel(
        type: Bool.self,
        title: "Established Customer"
    )
}
```

## Step 3: Build the SwiftUI Interface

Connect your form model to SwiftUI views using the provided field components:

```swift
struct PersonEditView: View {
    @StateObject private var model = PersonEditModel()
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    FormTextField(model.firstName)
                    FormTextField(model.lastName)
                    FormTextField(model.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
                
                Section("Details") {
                    FormDatePickerField(model.birthday)
                        .datePickerStyle(.compact)
                    FormPickerField(model.sex)
                    FormToggleField(model.isEstablished)
                }
            }
            .navigationTitle("Edit Person")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        handleSave()
                    }
                    .disabled(!model.validate().isValid)
                }
            }
            .alert("Validation Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text("Please correct the errors in the form.")
            }
        }
    }
    
    private func handleSave() {
        let validationResult = model.validate()
        if validationResult.isValid {
            // Access the bound data model
            let person = model.value
            savePerson(person)
        } else {
            showingAlert = true
        }
    }
}
```

## Understanding Field Types

QuickForm provides specialized field view models for different data types and use cases:

### Basic Text Fields

```swift
// Simple text input
@PropertyEditor(keyPath: \Person.givenName)
var firstName = FormFieldViewModel(
    type: String.self,
    title: "First Name",
    placeholder: "Enter your first name",
    validation: .combined(.notEmpty, .maxLength(50))
)

// Optional text input
@PropertyEditor(keyPath: \Person.middleName)
var middleName = FormFieldViewModel(
    type: String?.self,
    title: "Middle Name",
    placeholder: "Optional"
)
```

### Formatted Fields

```swift
// Currency formatting
@PropertyEditor(keyPath: \Person.salary)
var salary = FormattedFieldViewModel(
    type: Decimal.self,
    format: .currency(code: "USD"),
    title: "Annual Salary",
    placeholder: "$75,000"
)

// Phone number formatting
@PropertyEditor(keyPath: \Person.phone)
var phone = FormattedFieldViewModel(
    type: String?.self,
    format: OptionalFormat(format: .usPhoneNumber(.parentheses)),
    title: "Phone Number",
    placeholder: "(555) 123-4567"
)
```

### Selection Fields

```swift
// Single selection from enum
@PropertyEditor(keyPath: \Person.sex)
var sex = PickerFieldViewModel(
    type: Person.Sex.self,
    allValues: Person.Sex.allCases,
    title: "Sex"
)

// Optional selection
@PropertyEditor(keyPath: \Address.state)
var state = OptionalPickerFieldViewModel(
    type: CountryState?.self,
    allValues: [],
    title: "State",
    placeholder: "Select a state"
)

// Multiple selection
@PropertyEditor(keyPath: \Person.skills)
var skills = MultiPickerFieldViewModel(
    value: [],
    allValues: Skill.allCases,
    title: "Skills"
)
```

### Collection Management

```swift
// Dynamic collection with add/remove functionality
@PropertyEditor(keyPath: \Person.educationHistory)
var education = FormCollectionViewModel(
    type: Education.self,
    title: "Education",
    insertionTitle: "Add Education"
)

// Tag-style collection input
@PropertyEditor(keyPath: \Person.hobbies)
var hobbies = TokenSetViewModel(
    value: [],
    title: "Hobbies",
    insertionPlaceholder: "Add a hobby"
) { hobbyName in
    Hobby(name: hobbyName)
}
```

## Advanced: Field Relationships

Use `@PostInit` to establish relationships between fields that update dynamically:

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
        placeholder: "Select state"
    )
    
    @PropertyEditor(keyPath: \Address.zipCode)
    var zipCode = FormFieldViewModel(
        type: String.self,
        title: "ZIP Code",
        placeholder: "12345"
    )
    
    @PostInit
    func configure() {
        // Update states when country changes
        country.onValueChanged { [weak self] newCountry in
            self?.state.allValues = newCountry.states
            self?.state.value = nil
            
            // Conditional validation and formatting
            if newCountry == .unitedStates {
                self?.zipCode.validation = .combined(.notEmpty, .usZipCode)
                self?.zipCode.placeholder = "12345"
            } else if newCountry == .canada {
                self?.zipCode.validation = .combined(.notEmpty, .canadianPostalCode)
                self?.zipCode.placeholder = "A1A 1A1"
            }
            
            // Require state only for countries that have states
            if self?.state.allValues.isEmpty == false {
                self?.state.validation = .of(.required())
            } else {
                self?.state.validation = nil
            }
        }
    }
}
```

## Advanced: Async Data Loading

Handle remote data sources with built-in loading and error states:

```swift
@PropertyEditor(keyPath: \Prescription.medication)
var medication = AsyncPickerFieldViewModel(
    value: nil,
    title: "Medication",
    valuesProvider: { searchQuery in
        try await MedicationService.searchMedications(query: searchQuery)
    },
    queryBuilder: { searchText in
        searchText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
)
```

## Advanced: Custom Validation

Create domain-specific validation rules:

```swift
struct AgeValidationRule: ValidationRule {
    func validate(_ form: PersonEditModel) -> ValidationResult {
        let age = Calendar.current.dateComponents([.year], from: form.birthday.value, to: Date()).year ?? 0
        
        if age < 18 {
            return .failure("Must be at least 18 years old")
        }
        if age > 120 {
            return .failure("Please enter a valid birth date")
        }
        return .success
    }
}

// Add to your form model
@PostInit
func configure() {
    addCustomValidationRule(AgeValidationRule())
}
```

## Advanced: Dependency Injection

For forms that need external services or dependencies:

```swift
@QuickForm(Order.self)
class OrderFormModel {
    struct Dependencies {
        let apiService: APIService
        let userDefaults: UserDefaults
    }
    
    @Dependency
    var dependencies: Dependencies
    
    @PropertyEditor(keyPath: \Order.items)
    var items: FormCollectionViewModel<OrderItem>
    
    @OnInit
    func setupFields() {
        // Initialize fields using injected dependencies
        items = FormCollectionViewModel(
            type: OrderItem.self,
            title: "Order Items"
        )
    }
    
    @PostInit
    func configure() {
        // Setup using dependencies
        loadDefaultValues()
    }
    
    private func loadDefaultValues() {
        // Use dependencies.userDefaults, dependencies.apiService, etc.
    }
}

// Usage with dependency injection
let dependencies = OrderFormModel.Dependencies(
    apiService: APIService(),
    userDefaults: .standard
)
let orderForm = OrderFormModel(dependencies: dependencies)
```

## Best Practices

### 1. Organize Complex Forms
Break large forms into logical sections using nested form models:

```swift
@QuickForm(Application.self)
class ApplicationFormModel: Validatable {
    @PropertyEditor(keyPath: \Application.personalInfo)
    var personalInfo = PersonalInfoFormModel()
    
    @PropertyEditor(keyPath: \Application.address)
    var address = AddressFormModel()
    
    @PropertyEditor(keyPath: \Application.experience)
    var experience = ExperienceFormModel()
}
```

### 2. Provide Meaningful Validation Messages
Use descriptive error messages that help users understand what's expected:

```swift
var email = FormFieldViewModel(
    type: String.self,
    title: "Email Address",
    placeholder: "your.email@company.com",
    validation: .combined(
        .notEmpty.withMessage("Email is required"),
        .email.withMessage("Please enter a valid email address")
    )
)
```

### 3. Leverage State Management
Use `@StateObserved` for UI state that doesn't belong in your data model:

```swift
@QuickForm(Registration.self)
class RegistrationFormModel: Validatable {
    // Form fields...
    
    @StateObserved
    var isLoading: Bool = false
    
    @StateObserved
    var showPasswordRequirements: Bool = false
    
    func submitRegistration() async {
        isLoading = true
        defer { isLoading = false }
        
        // Submit logic...
    }
}
```

## Next Steps

Now that you understand QuickForm's fundamentals, explore these advanced topics:

- **Custom Field Types**: Create specialized field view models for your domain
- **Complex Validation**: Build multi-field validation rules and conditional logic
- **Performance Optimization**: Handle large forms and collections efficiently
- **Accessibility**: Ensure your forms work well with VoiceOver and other assistive technologies

For comprehensive API documentation, see ``FormFieldViewModel``, ``ValidationRule``, and ``Validatable``.
