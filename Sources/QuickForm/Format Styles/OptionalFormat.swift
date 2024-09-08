import Foundation

public struct OptionalFormat<Value, F>: ParseableFormatStyle where F: ParseableFormatStyle, F.FormatInput == Value, F.FormatOutput == String {
    private let format: F
    public var parseStrategy: OptionalFormatStrategy<Value, F.Strategy> {
        OptionalFormatStrategy(strategy: format.parseStrategy)
    }

    public func format(_ value: Value?) -> String {
        if let value {
            format.format(value)
        } else {
            ""
        }
    }

    public init(format: F) {
        self.format = format
    }
}

public struct OptionalFormatStrategy<Value, S>: ParseStrategy where S: ParseStrategy, S.ParseInput == String, S.ParseOutput == Value {
    private let strategy: S
    public func parse(_ value: String) throws -> Value? {
        if value.isEmpty {
            nil
        } else {
            try strategy.parse(value)
        }
    }

    init(strategy: S) {
        self.strategy = strategy
    }
}

public struct PlainStringStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> String {
        value
    }
}

public struct PlainStringFormat: ParseableFormatStyle {
    public var parseStrategy: PlainStringStrategy {
        PlainStringStrategy()
    }

    public func format(_ value: String) -> String {
        value
    }

    public init() {}
}
