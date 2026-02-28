# AsyncSpy API Reference

`AsyncSpy` is the primary test double for controlling async operations. It uses `CheckedContinuation` to suspend callers and lets tests resume them with controlled results.

## Class Definition

```swift
@MainActor
public final class AsyncSpy { ... }
```

**Key:** AsyncSpy is `@MainActor`-isolated. All tests using it should be `@MainActor`.

## Core Methods

### `perform()` — Record a Call

Two overloads: one returning a value, one returning Void.

```swift
// Returning a value
public func perform<Result: Sendable, each Parameter: Sendable>(
    _ parameters: repeat each Parameter,
    tag: String? = nil
) async throws -> Result

// Void return
public func perform<each Parameter: Sendable>(
    _ parameters: repeat each Parameter,
    tag: String? = nil
) async throws
```

- Parameters are packed into `[(any Sendable)?]` and stored in `messages`.
- The call suspends via `withCheckedThrowingContinuation`.
- Use `tag` to distinguish multiple protocol methods on the same spy.

### `complete(with:at:)` — Resume with Success

```swift
public func complete(with result: some Sendable, at index: Int = 0)
```

- Resumes the continuation at `index` with the given value.
- Records an `Issue` if `index` is out of bounds.

### `complete(with:at:)` — Resume with Error

```swift
public func complete(with error: Error, at index: Int = 0)
```

### Inspection

```swift
public var callCount: Int                          // Total calls
public func callCount(forTag tag: String) -> Int   // Calls with specific tag
public func params(at index: Int) -> (params: [(any Sendable)?], tag: String?)
```

## Scenario API (Preferred)

### `scenario(yieldCount:_:)`

```swift
func scenario(
    yieldCount: Int = 1,
    _ body: (ScenarioStep) async throws -> Void
) async throws
```

- Wraps body in `withMainSerialExecutor` for deterministic scheduling.
- Auto-awaits all triggered tasks after body completes.
- Errors from triggered tasks are swallowed (intentional for error-path tests).

### ScenarioStep Methods

| Method | Purpose |
|--------|---------|
| `trigger(_ process:)` | Launch async SUT operation as tracked Task, yield |
| `trigger(sync: process)` | Call synchronous SUT method, yield for internal Tasks |
| `complete(with:at:)` | Resume spy continuation with success value |
| `fail(with:at:)` | Resume spy continuation with error |
| `cascade(_ completions:)` | Complete subsequent operations triggered by the first |

### CascadeCompletion Enum

```swift
enum CascadeCompletion {
    case void           // Complete with ()
    case success(any Sendable)  // Complete with value
    case failure(Error)  // Complete with error
    case skip           // Skip (operation didn't fire)
}
```

## Migration from Deprecated APIs

The old multi-closure APIs (`async {}`, `synchronous {}`, `asyncWithCascade {}`) are deprecated. Use `scenario {}` instead.

| Old Pattern | New Pattern |
|-------------|-------------|
| `spy.async { await sut.load() } completeWith: { .success(data) } expectationAfterCompletion: { ... }` | `spy.scenario { step in await step.trigger { await sut.load() }; await step.complete(with: data); ... }` |
| `spy.synchronous { sut.process() } completeWith: { .success(data) }` | `spy.scenario { step in await step.trigger(sync: { sut.process() }); await step.complete(with: data) }` |
| `spy.async { ... } expectationBeforeCompletion: { #expect(sut.isLoading) } completeWith: { ... }` | `spy.scenario { step in await step.trigger { ... }; #expect(sut.isLoading); await step.complete(with: ...) }` |
| `spy.asyncWithCascade { ... } completeWith: { .success(()) } cascade: { .init([.success(list)]) }` | `spy.scenario { step in await step.trigger { ... }; await step.complete(with: ()); await step.cascade(.success(list)) }` |
| `spy.async(at: 1) { await sut.reload() } completeWith: { .success(data) }` | `spy.scenario { step in await step.trigger { await sut.reload() }; await step.complete(with: data, at: 1) }` |

## Dual Framework Support

AsyncSpy has conditional compilation for both Swift Testing (`SourceLocation`) and XCTest (`StaticString file, UInt line`):

```swift
#if canImport(Testing)
    public func complete(with result: some Sendable, at index: Int = 0, sourceLocation: SourceLocation = #_sourceLocation)
#else
    public func complete(with result: some Sendable, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line)
#endif
```

## Source

`Sources/TestKit/Test Doubles/AsyncSpy.swift`
`Sources/TestKit/Test Doubles/CascadePolicy.swift`
