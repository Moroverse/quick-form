// CreditCardMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 04:59 GMT.

/// A mask for credit card numbers in the format XXXX XXXX XXXX XXXX
public struct CreditCardMask: AutoMask {
    public init() {}

    public func apply(to text: String) -> String {
        let digits = text.filter(\.isNumber)

        if digits.isEmpty {
            return ""
        }

        var result = ""
        var count = 0

        for digit in digits.prefix(19) { // Most credit cards are 16 digits, but allow for some variance
            if count > 0, count % 4 == 0 {
                result.append(" ")
            }
            result.append(digit)
            count += 1
        }

        return result
    }

    public func isAllowed(character: Character) -> Bool {
        character.isNumber
    }
}

public extension AutoMask where Self == CreditCardMask {
    /// Creates a standard credit card number mask in format XXXX XXXX XXXX XXXX
    static var creditCard: CreditCardMask { CreditCardMask() }
}
