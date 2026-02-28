---
name: test-kit
description: "Swift TestKit library: async test doubles (AsyncSpy, FireAndForgetSpy), scenario API, memory leak tracking, change tracking, Core Data test containers, sequential UUIDs, UI presentation spying. Use when writing Swift tests, creating test doubles, testing async operations, verifying memory leaks, or testing ViewModels with the Swift Testing framework."
---

# TestKit Skill

Write correct, idiomatic tests using the TestKit library for the Swift Testing framework. Covers async spy setup, scenario orchestration, memory leak detection, change tracking, Core Data test containers, and UI presentation testing.

## When to Use This Skill

Trigger when any of these applies:
- Writing or modifying Swift tests that use `import TestKit`
- Creating test doubles (spies, stubs) for async protocols
- Testing ViewModel async operations with controlled timing
- Testing fire-and-forget operations (sync methods spawning internal Tasks)
- Adding memory leak detection to tests
- Testing property changes with before/after assertions
- Setting up Core Data in-memory test containers
- Testing UIViewController present/dismiss behavior
- Generating deterministic UUIDs in tests
- Migrating from XCTest to Swift Testing framework

## Not For / Boundaries

- Not for general Swift Testing framework guidance without TestKit (use swift-concurrency skill)
- Not for Mockable/@Mock macro-based mocking (separate library)
- Not for XCTest-only projects that don't use TestKit
- Required: project must have `TestKit` as a dependency

## Quick Reference

### 1. AsyncSpy Protocol Conformance

Conform `AsyncSpy` to your protocol using `perform()` with variadic parameters and optional tags:

```swift
extension AsyncSpy: @retroactive MyProtocol {
    func fetchUser(id: Int) async throws -> User {
        try await perform(id, tag: "FetchUser")
    }
}
```

For void-returning methods:

```swift
extension AsyncSpy: @retroactive DeletionProtocol {
    func delete(id: String) async throws {
        try await perform(id, tag: "Delete")
    }
}
```

### 2. Scenario API (Primary Pattern)

The `scenario {}` API is the preferred way to orchestrate async tests. It wraps execution in `withMainSerialExecutor` for deterministic scheduling:

```swift
try await spy.scenario { step in
    await step.trigger { await sut.load() }
    #expect(sut.isLoading)
    await step.complete(with: expectedData)
    #expect(sut.items == expectedData)
}
```

### 3. Scenario with Error Path

```swift
try await spy.scenario { step in
    await step.trigger { await sut.load() }
    await step.fail(with: NetworkError.timeout)
    #expect(sut.error != nil)
}
```

### 4. Scenario with Cascade (Multi-Step Operations)

When one operation triggers another (e.g., delete then reload):

```swift
try await spy.scenario { step in
    await step.trigger { await sut.deleteAndReload(item) }
    await step.complete(with: ())                          // completes delete
    await step.cascade(.success(updatedList))              // completes reload
    #expect(sut.items == updatedList)
}
```

Use `.skip` when the cascading call doesn't fire (error path):

```swift
await step.cascade(.skip)
```

### 5. Synchronous Trigger (Hidden Async)

When the SUT method is synchronous but internally spawns a Task:

```swift
try await spy.scenario(yieldCount: 3) { step in
    await step.trigger(sync: { sut.loadViewIfNeeded() })
    await step.complete(with: data)
}
```

### 6. FireAndForgetSpy (Fire-and-Forget Operations)

For testing code that initiates async work through synchronous calls:

```swift
extension FireAndForgetSpy: UserServiceProtocol {
    func loadUser(id: Int) async throws -> User {
        try await perform(id, tag: "loadUser")
    }
}

try await spy.scenario { step in
    await step.trigger { sut.loadUser(id: 1) }    // synchronous call
    #expect(sut.isLoading)
    await step.complete(with: expectedUser)
    #expect(sut.user?.id == 1)
}
```

### 7. Parameter Verification

```swift
#expect(spy.callCount == 1)
#expect(spy.callCount(forTag: "Delete") == 1)
let params = spy.params(at: 0)
#expect(params.params[0] as? String == "encounter-1")
#expect(params.tag == "Delete")
```

### 8. Memory Leak Tracking

Track objects inside a `makeSUT()` factory; apply `.teardownTracking()` to every test that calls it:

```swift
@MainActor
@Suite struct MyViewModelTests {
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
        // ... test logic — tracked objects must deallocate after test
    }
}
```

Mark known leaks with `isKnowIssue`:

```swift
await Test.trackForMemoryLeaks(sut, isKnowIssue: true)
```

Never apply `.teardownTracking()` to @Sutite, ALWAYS apply `.teardownTracking()` to every test you want to testo for memory leaks. 

### 9. Change Tracking

```swift
await Test.trackChange(of: \.displayedItems, in: sut)
    .givenInitialState { sut.items = allItems }
    .expectInitialValue { allItems }
    .whenChanging { sut.filter = .active }
    .expectFinalValue { activeItems }
    .verify()
```

### 10. Core Data Test Container

```swift
@Suite("MyTests", .persistenceTestContainer(for: MyModel.model), .serialized)
struct MyTests {
    @Test func testWithCoreData() throws {
        try NSManagedObjectContext.withTestContext { context in
            // Use context for Core Data operations
        }
    }
}
```

### 11. Sequential UUID Generation

```swift
@Test("Deterministic UUIDs", .sequentialUUIDGeneration())
func testUUIDs() async throws {
    let uuid1 = try await UUID.incrementing()
    #expect(uuid1.uuidString == "00000000-0000-0000-0000-000000000000")
}
```

### 12. UI Presentation Spy

```swift
@Test("Presents alert", .serialized) @MainActor
func testPresentsAlert() async throws {
    let spy = PresentationSpy()
    let presenter = UIViewController()
    let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)

    presenter.present(alert, animated: true)

    #expect(spy.presentations.count == 1)
    #expect(spy.presentations[0].state == .presented)
}
```

### 13. Non-Sendable Types with UncheckedSendable

When AsyncSpy needs to return non-Sendable types (e.g., NSManagedObject subclasses):

```swift
// Document safety: both spy and test run on @MainActor
extension AsyncSpy: @retroactive DetailLoader {
    func load(id: String, context: NSManagedObjectContext) async throws -> ManagedObject {
        let box: UncheckedSendable<ManagedObject> = try await perform(id, tag: "Load")
        return box.wrappedValue
    }
}
```

### 14. Composite Spy (Wrapping AsyncSpy)

For protocols with mixed sync/async methods, wrap AsyncSpy in a dedicated spy class:

```swift
@MainActor
final class MyServiceSpy: MyService {
    let asyncSpy = AsyncSpy()
    private var stubs: [String: Any] = [:]

    func asyncMethod() async throws -> Data {
        try await asyncSpy.perform(tag: "async")
    }

    func syncMethod(id: String) -> Model? {
        stubs[id] as? Model
    }

    func stubModel(_ model: Model, id: String) {
        stubs[id] = model
    }
}
```

### 15. JSON Helpers

```swift
let json = Test.makeJSON(withObject: ["id": "1", "name": "Alice"])
let arrayJSON = Test.makeJSON(withObjects: [["id": "1"], ["id": "2"]])
try Test.assertEqual(encodedData, expectedJSON)
```

### 16. Localization Testing

```swift
let title = localized("screen.title", in: bundle)
assertLocalizedKeyAndValuesExist(in: bundle, "Localizable")
```

### 17. Task Cancellation in Scenario

```swift
try await spy.scenario { step in
    let task = await step.trigger { await sut.load() }
    task.cancel()
    await step.complete(with: data)
    #expect(sut.state == .cancelled)
}
```

### 18. yieldCount Tuning

Increase `yieldCount` when the SUT has multiple suspension points before reaching the spy:

```swift
try await spy.scenario(yieldCount: 3) { step in
    await step.trigger { await sut.complexMultiStepOperation() }
    await step.complete(with: result)
}
```

## AsyncSpy vs FireAndForgetSpy Decision

| Criterion | AsyncSpy | FireAndForgetSpy |
|-----------|----------|------------------|
| SUT method signature | `async throws -> T` | Synchronous (spawns internal Task) |
| You `await` the SUT call | Yes | No |
| Completion mechanism | `CheckedContinuation` | `AsyncThrowingStream` |
| Trigger in scenario | `step.trigger { await sut.method() }` | `step.trigger { sut.method() }` |
| Cancellation support | Via Task returned from `trigger` | Via `step.cancel()` |
| Result tracking | `spy.params(at:)`, `spy.callCount` | `spy.requests[i].result`, `spy.result(at:)` |

## Examples

### Example 1: Testing a ViewModel with AsyncSpy

**Goal:** Test that a ViewModel loads encounters, handles errors, and supports delete-then-reload.

```swift
import TestKit
import Testing
@testable import MyApp

// 1. Conform AsyncSpy to protocols
extension AsyncSpy: @retroactive EncounterLoader {
    func load(patientID: String) async throws -> [Encounter] {
        try await perform(patientID, tag: "Load")
    }
}

extension AsyncSpy: @retroactive EncounterDeleter {
    func delete(id: String) async throws {
        try await perform(id, tag: "Delete")
    }
}

// 2. Create composite spy
@MainActor
final class EncounterServiceSpy: EncounterService {
    let asyncSpy = AsyncSpy()

    func load(patientID: String) async throws -> [Encounter] {
        try await asyncSpy.load(patientID: patientID)
    }

    func delete(id: String) async throws {
        try await asyncSpy.delete(id: id)
    }
}

// 3. Write tests
@Suite("EncounterListViewModel", .serialized)
@MainActor
struct EncounterListViewModelTests {
    @Test("reload() loads encounters from service")
    func reloadLoadsEncounters() async throws {
        let spy = EncounterServiceSpy()
        let sut = EncounterListViewModel(service: spy)
        let encounters = [Encounter(id: "1", title: "Visit")]

        try await spy.asyncSpy.scenario { step in
            await step.trigger { await sut.reload() }
            #expect(sut.isLoading)
            await step.complete(with: encounters)
            #expect(!sut.isLoading)
            #expect(sut.items?.count == 1)
        }
    }

    @Test("reload() shows error on failure")
    func reloadShowsError() async throws {
        let spy = EncounterServiceSpy()
        let sut = EncounterListViewModel(service: spy)

        try await spy.asyncSpy.scenario { step in
            await step.trigger { await sut.reload() }
            await step.fail(with: TestError.testFailure)
            #expect(sut.alertDescriptor != nil)
        }
    }

    @Test("deleteEncounter() deletes then reloads")
    func deleteAndReload() async throws {
        let spy = EncounterServiceSpy()
        let sut = EncounterListViewModel(service: spy)

        try await spy.asyncSpy.scenario { step in
            await step.trigger { await sut.deleteEncounter("1") }
            await step.complete(with: ())                         // delete completes
            await step.cascade(.success([] as [Encounter]))       // reload completes
            #expect(spy.asyncSpy.callCount(forTag: "Delete") == 1)
            #expect(sut.items?.isEmpty == true)
        }
    }
}
```

### Example 2: Testing a Fire-and-Forget ViewModel

**Goal:** Test a ViewModel whose methods are synchronous but spawn internal async work.

```swift
import TestKit
import Testing
@testable import MyApp

extension FireAndForgetSpy: @retroactive DataSyncService {
    func sync(data: SyncPayload) async throws {
        try await perform(data, tag: "sync")
    }
}

@Suite("SyncViewModel", .serialized)
@MainActor
struct SyncViewModelTests {
    @Test("startSync() triggers sync and shows progress")
    func startSyncShowsProgress() async throws {
        let spy = FireAndForgetSpy()
        let sut = SyncViewModel(service: spy)

        try await spy.scenario { step in
            await step.trigger { sut.startSync() }   // synchronous call
            #expect(sut.isSyncing == true)
            await step.complete(with: ())
            #expect(sut.isSyncing == false)
            #expect(sut.lastSyncResult == .success)
        }

        #expect(spy.callCount == 1)
    }

    @Test("startSync() handles failure gracefully")
    func startSyncHandlesFailure() async throws {
        let spy = FireAndForgetSpy()
        let sut = SyncViewModel(service: spy)

        try await spy.scenario { step in
            await step.trigger { sut.startSync() }
            await step.fail(with: SyncError.networkUnavailable)
            #expect(sut.isSyncing == false)
            #expect(sut.errorMessage != nil)
        }
    }

    @Test("cancelSync() cancels pending operations")
    func cancelSyncCancelsPending() async throws {
        let spy = FireAndForgetSpy()
        let sut = SyncViewModel(service: spy)

        try await spy.scenario { step in
            await step.trigger { sut.startSync() }
            try await step.cancel()
            let result = try await spy.result(at: 0)
            #expect(result == .cancelled)
        }
    }
}
```

### Example 3: Core Data + Memory Leak Detection + Change Tracking

**Goal:** Test a ViewModel that uses Core Data, verify no leaks, and track property changes.

```swift
import TestKit
import Testing
@testable import MyApp

// Do not apply .teardownTracking() to @Suite.
@Suite(
    "PatientViewModel",
    .persistenceTestContainer(for: PatientModel.model),
    .serialized
)
@MainActor
struct PatientViewModelTests {
    // Factory tracks ALL objects for memory leaks.
    private func makeSUT() async throws -> (sut: PatientViewModel, loader: AsyncSpy<[Patient]>) {
        let loader = AsyncSpy<[Patient]>()
        let sut = try await NSManagedObjectContext.withTestContext { context in
            PatientViewModel(context: context, loader: loader.load)
        }
        await Test.trackForMemoryLeaks(sut)
        await Test.trackForMemoryLeaks(loader)
        return (sut, loader)
    }

    @Test("filter updates displayed patients", .teardownTracking())
    func filterUpdatesDisplayedPatients() async throws {
        let (sut, _) = try await makeSUT()
        let allPatients = [Patient.fixture(name: "Alice"), Patient.fixture(name: "Bob")]
        let activeOnly = [Patient.fixture(name: "Alice")]

        await Test.trackChange(of: \.displayedPatients, in: sut)
            .givenInitialState { sut.patients = allPatients }
            .expectInitialValue { allPatients }
            .whenChanging { sut.filter = .active }
            .expectFinalValue { activeOnly }
            .verify()
    }

    @Test("deterministic UUIDs for new patients", .sequentialUUIDGeneration(), .teardownTracking())
    func deterministicUUIDs() async throws {
        let uuid = try await UUID.incrementing()
        #expect(uuid.uuidString == "00000000-0000-0000-0000-000000000000")
    }
}
```

## References

- `references/index.md` — Navigation index for all reference docs
- `references/async-spy-api.md` — Full AsyncSpy API surface and migration guide
- `references/fire-and-forget-spy-api.md` — FireAndForgetSpy API and when to use it
- `references/traits-and-scoping.md` — Test traits (.teardownTracking, .persistenceTestContainer, .sequentialUUIDGeneration)
- `references/project-patterns.md` — Real patterns from the EZDERM codebase

## Maintenance

- Sources: test-kit library at `/Volumes/Ex_Machina/Developer/Moroverse/test-kit` (Package.swift, Sources/TestKit/)
- Positive examples: EZDERM project at `App/Tests/Core/SwiftUIFeatures/Encounters/`, state-kit at `/Volumes/Ex_Machina/Developer/Moroverse/state-kit/Tests/StateKitTests/`
- Last updated: 2026-02-13
- Known limits: UI testing (PresentationSpy, InstantAnimationStub) requires UIKit and is iOS-only
