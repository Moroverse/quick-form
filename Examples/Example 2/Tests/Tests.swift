// Tests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

@testable import ApplicationForm
import FactoryKit
import Foundation
import Testing

@Suite("AdditionalInfoModel Tests")
struct AdditionalInfoModelTests {
    @Test("Correct title on initialization")
    func configure() async throws {
        let value = AdditionalInfo(resume: nil, consentToBackgroundChecks: false)
        let sut = AdditionalInfoModel(
            value: value,
            dependencies: .init(
                documentUploader: Container.shared.documentUploader(),
                documentDeleter: Container.shared.documentDeleter(),
                router: { Container.shared.additionalInfoRouting() }
            )
        )

        #expect(sut.resume.title == "Resume:")
        #expect(sut.resume.placeholder == "Tap to upload a resume")
    }

    @Test("Tap on resume button starts upload if resume is selected")
    func onTapSelect() async throws {
        let spy = Spy()
        Container.shared.additionalInfoRouting.register { spy }
        Container.shared.documentUploader.register { spy }
        let value = AdditionalInfo(resume: nil, consentToBackgroundChecks: false)
        let sut = AdditionalInfoModel(
            value: value,
            dependencies: .init(
                documentUploader: Container.shared.documentUploader(),
                documentDeleter: Container.shared.documentDeleter(),
                router: { Container.shared.additionalInfoRouting() }
            )
        )

        let anyURL = URL(string: "https://www.example.com")!
        spy.selectedURL = anyURL
        spy.uploadResult = .failure(NSError(domain: "", code: 0, userInfo: nil))
        await sut.didTapOnAdditionalInformationResume()

        #expect(spy.messages.count == 2)
        if spy.messages.count == 2 {
            #expect(spy.messages[0] == .navigateToResumeUpload)
            #expect(spy.messages[1] == .uploadResume(at: anyURL))
        }
    }

    @Test("Tap on resume button navigates to upload if resume is missing")
    func onTap() async throws {
        let spy = Spy()
        Container.shared.additionalInfoRouting.register { spy }
        let value = AdditionalInfo(resume: nil, consentToBackgroundChecks: false)
        let sut = AdditionalInfoModel(
            value: value,
            dependencies: .init(
                documentUploader: Container.shared.documentUploader(),
                documentDeleter: Container.shared.documentDeleter(),
                router: { Container.shared.additionalInfoRouting() }
            )
        )

        await sut.didTapOnAdditionalInformationResume()

        #expect(spy.messages.count == 1)
        if spy.messages.count == 1 {
            #expect(spy.messages[0] == .navigateToResumeUpload)
        }
    }
}

final class Spy: AdditionalInfoRouting, DocumentUploader {
    func upload(from url: URL) async throws -> URL {
        messages.append(.uploadResume(at: url))
        switch uploadResult {
        case let .success(url):
            return url
        case let .failure(failure):
            throw failure
        case nil:
            Issue.record("No upload result provided")
            fatalError()
        }
    }

    enum Message: Equatable {
        case navigateToResumeUpload
        case navigateToPreview(at: URL)
        case uploadResume(at: URL)
    }

    var messages: [Message] = []
    var selectedURL: URL?
    var uploadResult: Result<URL, Error>?

    func navigateToResumeUpload() async -> URL? {
        messages.append(.navigateToResumeUpload)
        return selectedURL
    }

    func navigateToPreview(at url: URL) {
        messages.append(.navigateToPreview(at: url))
    }
}
