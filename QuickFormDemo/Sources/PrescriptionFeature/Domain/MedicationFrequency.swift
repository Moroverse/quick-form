// MedicationFrequency.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-17 18:13 GMT.

enum MedicationFrequency: Hashable {
    case timesPerPeriod(times: Int, period: TimePeriod)
    case everyPeriod(interval: Int, period: TimePeriod)
    case predefined(schedule: PredefinedSchedule)

    var simpleFrequency: SimpleFrequency {
        switch self {
        case .timesPerPeriod: .timesPerPeriod
        case .everyPeriod: .everyPeriod
        case .predefined: .predefined
        }
    }

    enum SimpleFrequency: Hashable, CaseIterable {
        case predefined
        case timesPerPeriod
        case everyPeriod

        var formatted: String {
            switch self {
            case .timesPerPeriod: "Times Per Period"
            case .everyPeriod: "Every Period"
            case .predefined: "Predefined"
            }
        }
    }

    var interval: Int? {
        switch self {
        case .timesPerPeriod(times: let times, period: _): times
        case .everyPeriod(interval: let interval, period: _): interval
        case .predefined: nil
        }
    }

    var timePeriod: TimePeriod? {
        switch self {
        case .timesPerPeriod(times: _, period: let period): period
        case .everyPeriod(interval: _, period: let period): period
        case .predefined: nil
        }
    }

    enum TimePeriod: Hashable, CaseIterable {
        case hour
        case day
        case week
        case month

        var formatted: String {
            switch self {
            case .hour: "Hour"
            case .day: "Day"
            case .week: "Week"
            case .month: "Month"
            }
        }
    }

    enum PredefinedSchedule: String, CaseIterable {
        // swiftlint:disable:next identifier_name
        case qd = "Once daily"
        case bid = "Twice daily"
        case tid = "Three times daily"
        case qid = "Four times daily"
        case qhs = "Every bedtime"
        case q4h = "Every 4 hours"
        case q6h = "Every 6 hours"
        case q8h = "Every 8 hours"
        // Add more predefined schedules as needed
    }

    var formatted: String {
        switch self {
        case let .timesPerPeriod(times: times, period: period):
            "\(times) times per \(period.formatted)".lowercased()
        case let .everyPeriod(interval: interval, period: period):
            "Every \(interval) \(period.formatted)".lowercased()
        case let .predefined(predefined):
            "\(predefined.rawValue)".lowercased()
        }
    }
}
