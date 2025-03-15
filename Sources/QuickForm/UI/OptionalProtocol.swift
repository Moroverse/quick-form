protocol OptionalProtocol {
    var wrappedValue: Any? { get }
}

extension Optional: OptionalProtocol {
    var wrappedValue: Any? {
        return self.map { $0 }
    }
}
