// QuickFormMacro.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// QuickFormMacro.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

public struct QuickFormMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.invalidDeclaration
        }

        guard case let .argumentList(arguments) = node.arguments,
              let firstArg = arguments.first?.expression.as(MemberAccessExprSyntax.self),
              let modelType = firstArg.base?.as(DeclReferenceExprSyntax.self)?.baseName.text else {
            throw MacroError.invalidArguments
        }

        let propertyEditors = classDecl.memberBlock.members.compactMap { member -> (String, String)? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let propertyEditorAttr = varDecl.attributes.first(where: {
                      $0.as(AttributeSyntax.self)?
                          .attributeName.as(IdentifierTypeSyntax.self)?
                          .name.text == "PropertyEditor"
                  })
            else { return nil }

            guard case let .argumentList(arguments) = propertyEditorAttr.as(AttributeSyntax.self)?.arguments,
                  let keyPathArg = arguments.first?.expression.as(KeyPathExprSyntax.self)
            else { return nil }
            let keyPaths = keyPathArg.components.compactMap {
                $0.component.as(KeyPathPropertyComponentSyntax.self)?.declName.baseName.text
            }
            guard keyPaths.isEmpty == false else {
                return nil
            }
            let keyPath = keyPaths.joined(separator: ".")
            return (identifier, "\\\(modelType).\(keyPath)")
        }

        // Find all properties annotated with @Dependency
        let dependencies = classDecl.memberBlock.members.compactMap { member -> (name: String, type: String)? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let type = binding.typeAnnotation?.type,
                  varDecl.attributes.first(where: {
                      $0.as(AttributeSyntax.self)?
                          .attributeName.as(IdentifierTypeSyntax.self)?
                          .name.text == "Dependency"
                  }) != nil
            else {
                return nil
            }

            return (identifier, type.description)
        }

        let dependencyParams = dependencies.isEmpty ? "" : ", " + dependencies.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
        let dependencyAssignments = dependencies.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n    ")

        // Find method annotated with @PostInit
        let funcDecls = classDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        let postInitMethod = funcDecls.first {
            let postInitAttribute = $0.attributes.first(where: {
                $0.as(AttributeSyntax.self)?
                    .attributeName.as(IdentifierTypeSyntax.self)?
                    .name.text == "PostInit"
            })
            return postInitAttribute != nil
        }

        let postInitCall = postInitMethod.map { "\($0.name)()" } ?? ""

        // Find methods annotated with @OnInit
        let onInitMethods = funcDecls.filter {
            $0.attributes.first(where: {
                $0.as(AttributeSyntax.self)?
                    .attributeName.as(IdentifierTypeSyntax.self)?
                    .name.text == "OnInit"
            }) != nil
        }
        // Extract the contents of these methods
        let onInitContents = onInitMethods.compactMap { method -> String? in
            guard let body = method.body else { return nil }
            // Remove the outer braces and extract the content
            let content = body.statements.description
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return content
        }

        let conformsToValidatable = classDecl.inheritanceClause?.inheritedTypes.contains { type in
            type.type.as(IdentifierTypeSyntax.self)?.name.text == "Validatable"
        } ?? false

        let classVisibility = classDecl.modifiers.first { $0.name.text == "public" || $0.name.text == "internal" }?.name.text ?? "internal"

        var declarations: [DeclSyntax] = []

        // Add model property
        let modelVar = """
        \(classVisibility) var value: \(modelType) {
            get {
                access(keyPath: \\.value)
                return _value
            }
            set {
                withMutation(keyPath: \\.value) {
                    _value = newValue
                    dispatcher.publish(newValue)
                }
            }
        }
        private var _value: \(modelType)
        """
        declarations.append(DeclSyntax(stringLiteral: modelVar))

        // Add update method
        let updateMethodContent = propertyEditors.map { identifier, keyPath in
            """
            \(identifier).value = _value[keyPath: \(keyPath)]
            """
        }.joined(separator: "\n")

        let updateMethod = """
        \(classVisibility) func update() {
            \(updateMethodContent)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: updateMethod))

        // Add initializer
        let initializer = """
        \(classVisibility) init(value: \(modelType)\(dependencyParams)) {
            self._value = value
            dispatcher = Dispatcher()
            \(dependencyAssignments.isEmpty ? "" : dependencyAssignments + "\n")
            \(onInitContents.joined(separator: "\n"))
            update()
        
            \(propertyEditors.map { identifier, keyPath in
                "track\(identifier.capitalized)()"
            }.joined(separator: "\n"))
            \(postInitCall)
        }
        
        \(propertyEditors.map { identifier, keyPath in
                makeTrack(identifier: identifier, keyPath: keyPath, shouldValidate: conformsToValidatable)
            }.joined(separator: "\n"))
        """
        declarations.append(DeclSyntax(stringLiteral: initializer))

        // Add observation registrar
        let observationRegistrar = """
        private let _$observationRegistrar = Observation.ObservationRegistrar()
        """
        declarations.append(DeclSyntax(stringLiteral: observationRegistrar))

        // Add access method
        let accessMethod = """
        internal nonisolated func access<Member>(
            keyPath: KeyPath<\(classDecl.name), Member>
        ) {
            _$observationRegistrar.access(self, keyPath: keyPath)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: accessMethod))

        // Add withMutation method
        let withMutationMethod = """
        internal nonisolated func withMutation<Member, MutationResult>(
            keyPath: KeyPath<\(classDecl.name), Member>,
            _ mutation: () throws -> MutationResult
        ) rethrows -> MutationResult {
            try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: withMutationMethod))

        if conformsToValidatable {
            // Add observable validationResult property
            let validationResultProperty = """
            \(classVisibility) private(set) var validationResult: ValidationResult {
                get {
                    access(keyPath: \\.validationResult)
                    return _validationResult
                }
                set {
                    withMutation(keyPath: \\.validationResult) {
                        _validationResult = newValue
                    }
                }
            }
            private var _validationResult: ValidationResult = .success
            """

            declarations.append(DeclSyntax(stringLiteral: validationResultProperty))

            // Add validate method
            let validateMethod = """
            \(classVisibility) func validate() -> ValidationResult {
                let editors: [(String, Any)] =  [\(propertyEditors.map { identifier, _ in
                    "(\"\(identifier)\", \(identifier))"
                }.joined(separator: ", "))]
                let results = editors.compactMap {
                    if let validator = $0.1 as? Validatable {
                        return ($0.0, validator.validate())
                    } else {
                        return nil
                    }
                }

                var errors: [LocalizedStringResource] = []
                for (name, result) in results {
                    if case .failure(let error) = result {
                        let namedError: LocalizedStringResource = "\\(name) \\(error)"
                        errors.append(namedError)
                    }
                }

                // Apply custom validation rules
                for rule in customValidationRules {
                    let result = rule.validate(_value)
                    if case .failure(let error) = result {
                         errors.append(error)
                    }
                }

                if errors.isEmpty {
                    return .success
                } else {
                    let list = errors.map{" - " + String(localized:$0)}.joined(separator: ",\\n")
                    let error: LocalizedStringResource = "Object has invalid fields:\\n\\(list)"
                    return .failure(error)
                }
            }
            """
            declarations.append(DeclSyntax(stringLiteral: validateMethod))
        }
        let customValidationRules = """
        private var customValidationRules: [any ValidationRule<\(modelType)>] = []

        \(classVisibility) func addCustomValidationRule(_ rule: some ValidationRule<\(modelType)>) {
            customValidationRules.append(rule)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: customValidationRules))

        // add dispatcher
        let dispatcher = """
        private var dispatcher: Dispatcher
        """
        declarations.append(DeclSyntax(stringLiteral: dispatcher))

        // add onValueChanged method
        let onValueChangedMethod = """
        @discardableResult
        \(classVisibility) func onValueChanged(_ change: @escaping (\(modelType)) -> Void) -> Subscription {
            dispatcher.subscribe(handler: change)
        }
        """
        declarations.append(DeclSyntax(stringLiteral: onValueChangedMethod))

        return declarations
    }

    static func makeTrack(identifier: String, keyPath: String, shouldValidate: Bool) -> String {
        let CapitalizedIdentifier = identifier.capitalized
        let validation = shouldValidate ? "validationResult = validate()" : ""
        let track =
            """
            private func track\(CapitalizedIdentifier)() {
                withObservationTracking { [weak self] in
                        _ = self?.\(identifier).value
                    } onChange: { [weak self] in
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            self.value[keyPath: \(keyPath)] = \(identifier).value
                            \(validation)
                            self.track\(CapitalizedIdentifier)()
                        }
                    }
                }
            """

        return track
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let observableConformance = try ExtensionDeclSyntax("extension \(type): Observable { }")
        let valueEditorConformance = try ExtensionDeclSyntax("extension \(type): ObservableValueEditor { }")
        return [observableConformance, valueEditorConformance]
    }
}

enum MacroError: Error {
    case invalidDeclaration
    case invalidArguments
}
