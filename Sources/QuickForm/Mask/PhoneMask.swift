// PhoneMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 04:59 GMT.

/// A mask for phone numbers in the format (XXX) XXX-XXXX
public struct PhoneMask: AutoMask {
    public init() {}

    public func apply(to text: String) -> String {
        let digits = text.filter(\.isNumber)

        if digits.isEmpty {
            return ""
        }

        var result = ""
        let digitArray = Array(digits)

        // Area code
        if !digitArray.isEmpty {
            result.append("(")
            result.append(String(digitArray.prefix(min(3, digitArray.count))))

            if digitArray.count > 3 {
                result.append(") ")

                // First three digits after area code
                let nextThree = digitArray[3 ..< min(6, digitArray.count)]
                result.append(String(nextThree))

                if digitArray.count > 6 {
                    result.append("-")

                    // Final four digits
                    let final = digitArray[6 ..< min(10, digitArray.count)]
                    result.append(String(final))
                }
            }
        }

        return result
    }

    public func isAllowed(character: Character) -> Bool {
        character.isNumber
    }
}

public extension AutoMask where Self == PhoneMask {
    /// Creates a standard US phone number mask in format (XXX) XXX-XXXX
    static var phone: PhoneMask { PhoneMask() }
}
