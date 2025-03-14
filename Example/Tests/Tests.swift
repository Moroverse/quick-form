// Tests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:00 GMT.

@testable import Example
import Factory
import Foundation
import Testing

@Suite("AdditionalInfoModel Tests")
struct AdditionalInfoModelTests {
    @Test("Correct title on initialization")
    func configure() async throws {
        let value = AdditionalInfo(resume: .missing)
        let sut = AdditionalInfoModel(value: value)

        #expect(sut.resume.title == "No Resume.")
    }

    @Test("Correct title is set on resume change")
    func onResumeChange() async throws {
        let value = AdditionalInfo(resume: .missing)
        let sut = AdditionalInfoModel(value: value)

        let anyURL = URL(string: "https://www.example.com")!
        let anyError: Error = NSError(domain: "", code: 0, userInfo: nil)
        sut.resume.value = .present(url: anyURL)
        #expect(sut.resume.title == "Resume uploaded.")
        sut.resume.value = .missing
        #expect(sut.resume.title == "No Resume.")
        sut.resume.value = .error(anyError)
        var errorTitle = sut.resume.title
        errorTitle.locale = Locale(identifier: "en_US_POSIX")
        #expect(String(localized: errorTitle) == "Resume upload error The operation couldn’t be completed. ( error 0.)")
    }

    @Test("Tap on resume button starts upload if resume is selected")
    func onTapSelect() async throws {
        let spy = Spy()
        Container.shared.additionalInfoRouting.register { spy }
        Container.shared.documentUploader.register { spy }
        let value = AdditionalInfo(resume: .missing)
        let sut = AdditionalInfoModel(value: value)

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
        let value = AdditionalInfo(resume: .missing)
        let sut = AdditionalInfoModel(value: value)

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
