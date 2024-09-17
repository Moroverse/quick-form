//
//  MedicationFrequency.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//


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

        var toString: String {
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

        var toString: String {
            switch self {
            case .hour: "Hour"
            case .day: "Day"
            case .week: "Week"
            case .month: "Month"
            }
        }
    }

    enum PredefinedSchedule: String, CaseIterable {
        case QD = "Once daily"
        case BID = "Twice daily"
        case TID = "Three times daily"
        case QID = "Four times daily"
        case QHS = "Every bedtime"
        case Q4H = "Every 4 hours"
        case Q6H = "Every 6 hours"
        case Q8H = "Every 8 hours"
        // Add more predefined schedules as needed
    }
}