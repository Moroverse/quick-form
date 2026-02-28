# EZDERM Project Patterns

Real-world patterns from the EZDERM iOS codebase demonstrating idiomatic TestKit usage.

## Pattern 1: @retroactive Protocol Conformance on AsyncSpy

Since `AsyncSpy` is from an external package, protocol conformances use `@retroactive`:

```swift
extension AsyncSpy: @retroactive ChartEncounterCreator {
    public func create(request: VirtualEncounterRequest) async throws -> String {
        try await perform(request, tag: "Create")
    }
}

extension AsyncSpy: @retroactive ChartEncounterFilterLoader {
    public func filter(query: EncounterFilterQuery, dateProvider: Date) async throws -> [ChartEncounter] {
        try await perform(query, dateProvider, tag: "Load")
    }
}

extension AsyncSpy: @retroactive ChartEncounterDeleter {
    public func delete(encounterID: String, patientID: String) async throws {
        try await perform(encounterID, patientID, tag: "Delete")
    }
}
```

**Convention:** Use `tag` parameter to distinguish operations. Tags are short verbs: `"Create"`, `"Load"`, `"Delete"`, `"Update"`.

## Pattern 2: Composite Spy Class

When a protocol has both sync and async methods, or needs additional stubbing:

```swift
@MainActor
final class ChartEncounterServiceSpy: ChartEncounterService {
    struct EncounterKey: Hashable {
        let id: String
        let patientID: String
    }

    let asyncSpy = AsyncSpy()
    private var encounterStubs: [EncounterKey: ChartEncounter] = [:]
    private(set) var encounterRequests: [EncounterKey] = []

    // Async methods delegate to asyncSpy
    func create(request: VirtualEncounterRequest) async throws -> String {
        try await asyncSpy.create(request: request)
    }

    func delete(encounterID: String, patientID: String) async throws {
        try await asyncSpy.delete(encounterID: encounterID, patientID: patientID)
    }

    // Sync methods use local stubs
    func encounter(withID id: String, patientID: String) -> ChartEncounter? {
        let key = EncounterKey(id: id, patientID: patientID)
        encounterRequests.append(key)
        return encounterStubs[key]
    }

    func stubEncounter(_ encounter: ChartEncounter, id: String, patientID: String) {
        encounterStubs[EncounterKey(id: id, patientID: patientID)] = encounter
    }
}
```

**Usage in tests:**

```swift
let (sut, spy) = makeSUT(...)

try await spy.asyncSpy.scenario { step in
    await step.trigger { await sut.reload() }
    await step.complete(with: encounters)
    #expect(sut.items?.count == 3)
}
```

## Pattern 3: UncheckedSendable for Non-Sendable Types

When `AsyncSpy.perform` needs to return non-Sendable types (e.g., `NSManagedObject` subclasses):

```swift
// Safety comment is REQUIRED when using UncheckedSendable
// AsyncSpy.perform requires `Result: Sendable` (CheckedContinuation constraint).
// EZEncounter is a non-Sendable managed object, so we box it in UncheckedSendable.
// This is safe because both AsyncSpy and the test suite run on @MainActor — the
// value never actually crosses an isolation boundary.
extension AsyncSpy: @retroactive ChartEncounterDetailLoader {
    func load(encounterID: String, patientID: String, context: NSManagedObjectContext) async throws -> EZEncounter {
        let box: UncheckedSendable<EZEncounter> = try await perform(encounterID, patientID, tag: "DetailLoad")
        return box.wrappedValue
    }
}
```

**Rule:** Always document why UncheckedSendable is safe in the specific context.

## Pattern 4: makeSUT Factory

Tests use a private `makeSUT` factory to create the system under test with its dependencies:

```swift
@MainActor
private func makeSUT(
    deletionStrategy: EncounterDeletionStrategy = .init(currentUserID: "1"),
    context: NSManagedObjectContext = .init(concurrencyType: .mainQueueConcurrencyType),
    user: EZUser = anyUser()
) -> (sut: EncounterListViewModel, spy: ChartEncounterServiceSpy) {
    let spy = ChartEncounterServiceSpy()
    let sut = EncounterListViewModel(
        service: spy,
        deletionStrategy: deletionStrategy,
        context: context,
        user: user
    )
    return (sut, spy)
}
```

## Pattern 5: @Suite with .serialized and Traits

```swift
@Suite("EncounterListViewModel", .serialized)
@MainActor
struct EncounterListViewModelTests {
    @Test("reload() loads encounters from service")
    func reloadLoadsEncounters() async throws {
        let (sut, spy) = makeSUT(...)
        // ...
    }
}
```

**Convention:** `.serialized` is used for tests that share mutable state or use method swizzling.

## Pattern 6: Testing Delete-then-Reload Cascade

```swift
@Test("deleteEncounter() deletes then reloads list")
func deleteAndReload() async throws {
    let (sut, spy) = makeSUT(...)

    // Pre-populate list
    try await spy.asyncSpy.scenario { step in
        await step.trigger { await sut.reload() }
        await step.complete(with: encounters)
    }

    let encounterToDelete = sut.items!.first!

    // Delete triggers reload
    try await spy.asyncSpy.scenario { step in
        await step.trigger { await sut.deleteEncounter(encounterToDelete) }
        await step.complete(with: ())                             // delete
        await step.cascade(.success(remainingEncounters))         // reload
        #expect(spy.asyncSpy.callCount(forTag: "Delete") == 1)
        #expect(sut.items?.count == remainingEncounters.count)
    }
}
```

## Pattern 7: Testing Error Paths

```swift
@Test("reload() shows error alert on failure")
func reloadShowsError() async throws {
    let (sut, spy) = makeSUT(...)

    try await spy.asyncSpy.scenario { step in
        await step.trigger { await sut.reload() }
        await step.fail(with: TestError.testFailure)
        #expect(sut.alertDescriptor != nil)
        #expect(sut.alertDescriptor?.title == "Error")
        #expect(sut.items == nil)
    }
}
```

## Pattern 8: Verifying Parameters

```swift
try await spy.asyncSpy.scenario { step in
    await step.trigger { await sut.saveTitle("New Title", forEncounter: encounter) }
    await step.complete(with: ())
    await step.cascade(.success([] as [ChartEncounter]))

    let params = spy.asyncSpy.params(at: 0)
    #expect(params.params[0] as? String == "New Title")
    #expect(params.params[1] as? String == "encounter-1")
    #expect(params.params[2] as? String == "patient-1")
    #expect(params.tag == "Update")
}
```

## Pattern 9: PresentationSpy with Scenario

```swift
@Test("shows error alert on load failure")
@MainActor
func showsAlertOnFailure() async throws {
    let presentationSpy = PresentationSpy()
    let (sut, spy) = makeSUT()

    try await spy.scenario { step in
        await step.trigger(sync: { sut.loadViewIfNeeded() })
        await step.fail(with: anyNSError())
        #expect(presentationSpy.presentations.count == 1)
        #expect(presentationSpy.presentations.first?.controller is UIAlertController)
    }
}
```

## Source Files

- `App/Tests/Core/SwiftUIFeatures/Encounters/Helpers/EncounterTestSpies.swift`
- `App/Tests/Core/SwiftUIFeatures/Encounters/Presentation/EncounterListViewModelTests.swift`
- `App/Tests/Core/SwiftUIFeatures/Encounters/Services/CachingChartEncounterServiceTests.swift`
- `App/Tests/Composition/Admin/Clinics/ClinicBillingLocalityViewControllerTests.swift`
