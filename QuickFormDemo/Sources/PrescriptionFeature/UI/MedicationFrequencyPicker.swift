//
//  MedicationFrequencyPicker.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 16.9.24..
//

import SwiftUI
import QuickForm

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

struct MedicationFrequencyPicker: View {
    @Bindable private var viewModel: FormFieldViewModel<MedicationFrequency>
    @State private var simpleFrequency: MedicationFrequency.SimpleFrequency
    @State private var times: Int
    @State private var period: MedicationFrequency.TimePeriod
    @State private var schedule: MedicationFrequency.PredefinedSchedule
    var body: some View {
        VStack {
            Picker("Frequencty", selection: $simpleFrequency) {
                ForEach(MedicationFrequency.SimpleFrequency.allCases, id: \.hashValue) { simpleFrequency in
                    Text(simpleFrequency.toString)
                        .tag(simpleFrequency, includeOptional: true)
                }
            }
            .pickerStyle(.segmented)

            switch simpleFrequency {
            case .predefined:
                PredefinedSchedulePicker(schedule: $schedule)
            case .timesPerPeriod:
                TimesPerPeriodPicker(times: $times, period: $period)
            case .everyPeriod:
                EveryPeriodPicker(times: $times, period: $period)
            }
        }
        .padding()
        .onChange(of: schedule) { _, newValue in
            viewModel.value = .predefined(schedule: newValue)
        }
        .onChange(of: times) { _, newValue in
            switch simpleFrequency {
            case .predefined:
                break
            case .timesPerPeriod:
                viewModel.value = .timesPerPeriod(times: newValue, period: period)
            case .everyPeriod:
                viewModel.value = .everyPeriod(interval: newValue, period: period)
            }
        }
        .onChange(of: period) { _, newValue in
            switch simpleFrequency {
            case .predefined:
                break
            case .timesPerPeriod:
                viewModel.value = .timesPerPeriod(times: times, period: newValue)
            case .everyPeriod:
                viewModel.value = .everyPeriod(interval: times, period: newValue)
            }
        }
        .onChange(of: simpleFrequency) { _, newValue in
            switch newValue {
            case .predefined:
                viewModel.value = .predefined(schedule: schedule)
            case .timesPerPeriod:
                viewModel.value = .timesPerPeriod(times: times, period: period)
            case .everyPeriod:
                viewModel.value = .everyPeriod(interval: times, period: period)
            }
        }
    }

    init(viewModel: FormFieldViewModel<MedicationFrequency>) {
        self.viewModel = viewModel
        self.simpleFrequency = viewModel.value.simpleFrequency
        self.times = viewModel.value.interval ?? 1
        self.period = viewModel.value.timePeriod ?? .hour
        self.schedule = .BID
    }
}

struct PredefinedSchedulePicker: View {
    @Binding var schedule: MedicationFrequency.PredefinedSchedule
    var body: some View {
        Picker("Schedule", selection: $schedule) {
            ForEach(MedicationFrequency.PredefinedSchedule.allCases, id: \.self) { schedule in
                Text(schedule.rawValue)
            }
        }
        .pickerStyle(.wheel)
    }
}

struct EveryPeriodPicker: View {
    @Binding var times: Int
    @Binding var period: MedicationFrequency.TimePeriod
    var body: some View {
        HStack {
            Text("Every")
            Picker("Times", selection: $times) {
                ForEach(1..<100) { number in
                    Text(number.formatted())
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            Picker("Period", selection: $period) {
                ForEach(MedicationFrequency.TimePeriod.allCases, id: \.self) { schedule in
                    Text(schedule.toString)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct TimesPerPeriodPicker: View {
    @Binding var times: Int
    @Binding var period: MedicationFrequency.TimePeriod
    var body: some View {
        HStack {
            Picker("Times", selection: $times) {
                ForEach(1..<100) { number in
                    Text(number.formatted())
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            Text("times per")
            Picker("Period", selection: $period) {
                ForEach(MedicationFrequency.TimePeriod.allCases, id: \.self) { schedule in
                    Text(schedule.toString)
                }
            }
            .pickerStyle(.wheel)

        }
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: MedicationFrequency.predefined(schedule: .BID),
        title: "Take"
    )
    Form {
        MedicationFrequencyPicker(viewModel: viewModel)
    }
}
