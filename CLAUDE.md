# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuickForm is a Swift package for creating declarative form-based UIs in SwiftUI with automatic data binding and validation. It uses Swift macros extensively to reduce boilerplate code for form creation.

## Key Architecture Components

### Core Protocols
- `ValueEditor<Value>`: Base protocol for types that can edit values
- `ObservableValueEditor`: Extends ValueEditor with change observation capabilities  
- `Validatable`: Protocol for types that can validate themselves

### Macro System
The project heavily relies on Swift macros defined in `Sources/QuickFormMacros/`:
- `@QuickForm(Type.self)`: Main macro that generates form infrastructure, Observable conformance, and validation support
- `@PropertyEditor(keyPath:)`: Creates two-way binding between form fields and model properties
- `@PostInit`: Marks methods to run after initialization (for setup that requires all properties initialized)
- `@OnInit`: Marks methods to run during initialization
- `@Dependency`: Marks properties for dependency injection

### Form Field ViewModels
Located in `Sources/QuickForm/Property View Models/`:
- `FormFieldViewModel<T>`: Basic form field with validation
- `FormattedFieldViewModel<T>`: Field with input formatting/masking
- `PickerFieldViewModel<T>`: Single selection picker
- `MultiPickerFieldViewModel<T>`: Multiple selection picker
- `AsyncPickerFieldViewModel<T>`: Async data loading picker
- `FormCollectionViewModel<T>`: Dynamic collections of form fields

### SwiftUI Views
Located in `Sources/QuickForm/UI/SwiftUI/Fields/`:
- Form field components like `FormTextField`, `FormPickerField`, `FormDatePickerField`, etc.
- Each corresponds to a specific view model type

### Validation System
Located in `Sources/QuickForm/Validation/`:
- `ValidationRule` protocol and implementations
- Built-in rules: `RequiredRule`, `EmailRule`, `MaxLengthRule`, `MinLengthRule`, etc.
- `AnyValidationRule` for rule composition

## Development Commands

### Project Setup
```bash
make all                    # Complete setup: upgrade mise, install deps, setup Tuist
make install               # Install dependencies with mise
make generate              # Generate Xcode project with Tuist
make clean                 # Clean build artifacts and git clean
```

### Testing
```bash
swift test                 # Run all tests
swift test --filter <name> # Run specific test
```

### Documentation
```bash
bash scripts/docc.sh QuickForm        # Build DocC documentation for all platforms
bash scripts/docc.sh QuickForm iOS    # Build for specific platform
```

### Build
```bash
swift build                # Build the package
swift build -c release     # Release build
```

## Project Structure Notes

- Examples in `Examples/` show real-world usage patterns
- Tuist is used for project generation (see `Tuist/` and `Project.swift` files)
- Documentation is written in DocC format (`Sources/QuickForm/Documentation.docc/`)
- Macro implementations are in separate target `QuickFormMacros`
- Swift 6.0+ and iOS 17.0+/macOS 14.0+ minimum requirements

## Testing Strategy

- Unit tests for view models, validation rules, and utilities
- Macro tests using swift-macro-testing framework
- SwiftUI view tests using ViewInspector
- Tests are in `Tests/QuickFormTests/` mirroring source structure

## Key Patterns

- Heavy use of property wrappers and macros for declarative syntax
- Protocol-oriented design with extensive use of generics
- Reactive programming patterns with value change observation
- Separation of view models from SwiftUI views for testability