# FireAndForgetSpy API Reference

`FireAndForgetSpy` is for testing code that initiates async work through **synchronous** method calls (fire-and-forget pattern). Unlike `AsyncSpy`, it uses `AsyncThrowingStream` instead of `CheckedContinuation`.

## When to Use

- The SUT method is **synchronous** but internally spawns a `Task`
- You do **not** `await` the SUT call in the test
- Common in ViewModels: `func loadData()` (not `func loadData() async throws`)

## Class Definition

```swift
@MainActor
public final class FireAndForgetSpy { ... }
```

## Core Methods

### `perform()` — Record a Call

```swift
// Returning a value
public func perform<each Parameter, Resource: Sendable>(
    _ parameters: repeat each Parameter,
    tag: String? = nil
) async throws -> Resource

// Void return
public func perform<each Parameter>(
    _ parameters: repeat each Parameter,
    tag: String? = nil
) async throws
```

- Creates an `AsyncThrowingStream` per call.
- Parameters stored as `[Any]` in `requests`.
- Suspends by iterating the stream.

### `complete(with:at:)` — Resume with Success

```swift
func complete(with resource: some Sendable, at index: Int) async
```

- Yields the resource to the stream and finishes it.
- Polls with `Task.yield()` until the result state is set.

### `fail(with:at:)` — Resume with Error

```swift
func fail(with error: Error, at index: Int) async
```

### `cancelPendingRequests()` — Cancel All Pending

```swift
public func cancelPendingRequests() async throws
```

- Finishes all pending streams with `CancellationError`.
- Called automatically by `scenario {}` after body completes.

### `result(at:timeout:)` — Query Result State

```swift
public func result(at index: Int, timeout: TimeInterval = 1) async throws -> Result
```

Returns `.success`, `.failure`, or `.cancelled`.

### Inspection

```swift
public var callCount: Int
public func callCount(forTag tag: String) -> Int
public var requests: [(params: [Any], stream: ..., continuation: ..., tag: String?, result: Result?)]
```

## Result Enum

```swift
public enum Result: Equatable {
    case success    // Completed without error
    case failure    // Threw non-cancellation error
    case cancelled  // CancellationError or Task.isCancelled
}
```

## Scenario API

### `scenario(yieldCount:_:)`

```swift
func scenario(
    yieldCount: Int = 1,
    _ body: (ScenarioStep) async throws -> Void
) async throws
```

- Does **not** use `withMainSerialExecutor` (unlike AsyncSpy).
- Auto-cancels pending requests after body completes.

### ScenarioStep Methods

| Method | Purpose |
|--------|---------|
| `trigger(_ process:)` | Call synchronous SUT method, yield for internal Tasks |
| `complete(with:at:)` | Complete pending operation with value |
| `fail(with:at:)` | Fail pending operation with error |
| `cancel()` | Cancel all pending requests |
| `cascade(_ completions:)` | Complete subsequent cascading operations |

### CascadeCompletion Enum

```swift
enum CascadeCompletion {
    case void              // Complete with ()
    case success(any Sendable)  // Complete with value
    case failure(Error)    // Complete with error
    case skip              // Skip (operation didn't fire)
}
```

## Key Differences from AsyncSpy

| Aspect | AsyncSpy | FireAndForgetSpy |
|--------|----------|------------------|
| SUT call style | `await sut.method()` | `sut.method()` (sync) |
| Internal mechanism | `CheckedContinuation` | `AsyncThrowingStream` |
| `scenario` executor | `withMainSerialExecutor` | No executor wrapping |
| Auto-cleanup | Awaits triggered tasks | Cancels pending requests |
| Result tracking | `params(at:)` only | `requests[i].result` enum |
| Trigger in scenario | `step.trigger { await ... }` | `step.trigger { sut.method() }` |

## Source

`Sources/TestKit/Test Doubles/FireAndForgetSpy.swift`
