# Test Traits and Scoping Reference

TestKit provides custom `TestTrait`/`SuiteTrait` implementations that handle setup/teardown via the Swift Testing `TestScoping` protocol.

## TeardownTrackingTrait

**Trait:** `.teardownTracking()`
**Applies to:** `@Test` 

Enables memory leak tracking with `Test.trackForMemoryLeaks()`.

The standard pattern: track objects inside a `makeSUT()` factory; apply `.teardownTracking()` to the `@Suite` or each `@Test`:

```swift
// Do not apply .teardownTracking() to @Suite. Appy it on every test you want to track for memory leaks
@Suite(.teardownTracking())
@MainActor
struct MyViewModelTests {
    private func makeSUT() async -> (sut: MyViewModel, loader: AsyncSpy<[Item]>) {
        let loader = AsyncSpy<[Item]>()
        let sut = MyViewModel(loader: loader.load)
        await Test.trackForMemoryLeaks(sut)
        await Test.trackForMemoryLeaks(loader)
        return (sut, loader)
    }

  @Test(.teardownTracking())
  func load_setsLoadedState() async throws {
        let (sut, loader) = await makeSUT()
        // ... tracked objects must deallocate after test
    }
}
```

### How It Works

1. Creates a `TearDownBlocks` actor.
2. Sets it as `TearDownBlocks.$current` via `@TaskLocal`.
3. Runs the test function.
4. Runs one RunLoop cycle to flush pending main-queue work.
5. Executes all registered teardown blocks (which check weak references).

### `Test.trackForMemoryLeaks()`

```swift
public static func trackForMemoryLeaks(
    _ instance: AnyObject,
    isKnowIssue: Bool = false,
    sourceLocation: SourceLocation = #_sourceLocation
) async
```

- Creates a `WeakRef` to the instance.
- Registers a teardown block that asserts `weakRef.value == nil`.
- If `isKnowIssue: true`, wraps in `withKnownIssue {}`.
- **Requires** `.teardownTracking()` trait; records an Issue if missing.

## PersistenceTestContainerTrait

**Trait:** `.persistenceTestContainer(for:)`
**Applies to:** `@Suite` only (it's a `SuiteTrait`)

Sets up an in-memory Core Data container for the test suite.

```swift
@Suite("MyTests", .persistenceTestContainer(for: MyModel.model), .serialized)
struct MyTests { ... }
```

### How It Works

1. Creates a `PersistenceTestContainerManager` actor with the given `NSManagedObjectModel`.
2. The container uses `/dev/null` as the store URL (in-memory).
3. Sets `PersistenceTestContainerManager.$current` via `@TaskLocal`.

### Using the Test Context

```swift
// Async version
try await NSManagedObjectContext.withTestContext { context in
    // Use context — it's a private-queue child of the container's viewContext
}

// Sync version
try NSManagedObjectContext.withTestContext { context in
    // Same, but synchronous
}
```

Both versions reset the viewContext after the closure completes.

## TestContextTrait

**Trait:** `.testContext()`
**Applies to:** `@Test`

Creates a per-test `NSManagedObjectContext` available via `NSManagedObjectContext.test`.

```swift
@Test(.testContext())
func testWithContext() async throws {
    let context = NSManagedObjectContext.test
    // Use context directly
}
```

**Requires** a `PersistenceTestContainerManager` in the current `@TaskLocal` (i.e., the suite must use `.persistenceTestContainer(for:)`).

## SequentialUUIDGenerationTrait

**Trait:** `.sequentialUUIDGeneration()`
**Applies to:** `@Test` or `@Suite`

Provides deterministic, incrementing UUIDs.

```swift
@Test("Deterministic UUIDs", .sequentialUUIDGeneration())
func testUUIDs() async throws {
    let uuid1 = try await UUID.incrementing()
    // "00000000-0000-0000-0000-000000000000"

    let uuid2 = try await UUID.incrementing()
    // "00000000-0000-0000-0000-000000000001"
}
```

### How It Works

1. Creates a fresh `SequentialUUIDGenerator` actor.
2. Sets it as `SequentialUUIDGenerator.$current` via `@TaskLocal`.
3. Each call to `UUID.incrementing()` returns the next UUID in sequence.
4. Format: `00000000-0000-0000-0000-{12-digit hex counter}`

### Resetting

```swift
await UUID.reset()  // Resets counter to 0 within current TaskLocal scope
```

## Combining Traits

Traits can be combined on a single `@Suite` or `@Test`. Suite-level traits apply to all tests in the suite:

```swift
@Suite(
    "FullFeatureTests",
    .persistenceTestContainer(for: Model.model),
    .serialized
)
@MainActor
struct FullFeatureTests {
    // makeSUT tracks objects — every test inherits .teardownTracking() from @Suite
    private func makeSUT() async throws -> (sut: ViewModel, loader: AsyncSpy<[Item]>) {
        let loader = AsyncSpy<[Item]>()
        let sut = try await NSManagedObjectContext.withTestContext { context in
            ViewModel(context: context, loader: loader.load)
        }
        await Test.trackForMemoryLeaks(sut)
        await Test.trackForMemoryLeaks(loader)
        return (sut, loader)
    }

    @Test(.sequentialUUIDGeneration(), .teardownTracking())
    func testWithEverything() async throws {
        let (sut, loader) = try await makeSUT()
        let uuid = try await UUID.incrementing()
        // ... sut and loader are leak-checked after test completes
    }
}
```

## Source Files

- `Sources/TestKit/Testing/Test+TrackMemoryLeaks.swift`
- `Sources/TestKit/Testing/Test+Persistance.swift`
- `Sources/TestKit/Helpers/UUID+Incrementing.swift`
