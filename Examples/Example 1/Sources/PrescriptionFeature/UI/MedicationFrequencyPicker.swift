// MedicationFrequencyPicker.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-16 19:13 GMT.

import QuickForm
import SwiftUI

struct MedicationFrequencyPicker: View {
    @Bindable private var viewModel: FormFieldViewModel<MedicationFrequency?>
    @State private var simpleFrequency: MedicationFrequency.SimpleFrequency
    @State private var times: Int
    @State private var period: MedicationFrequency.TimePeriod
    @State private var schedule: MedicationFrequency.PredefinedSchedule
    @State private var isClosed: Bool = true
    var body: some View {
        HStack {
            Text(viewModel.title)
                .font(.headline)
            Spacer()
            Button(viewModel.value?.formatted ?? "Not Set") {
                withAnimation {
                    isClosed.toggle()
                    if isClosed == false {
                        updateValue(with: simpleFrequency)
                    }
                }
            }
            if shouldDisplayClearButton {
                Button {
                    viewModel.value = nil
                    isClosed = true
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .buttonStyle(.borderless)
            }
        }
        .disabled(viewModel.isReadOnly)
        if isClosed == false {
            VStack {
                Picker("Frequency", selection: $simpleFrequency) {
                    ForEach(MedicationFrequency.SimpleFrequency.allCases, id: \.hashValue) { simpleFrequency in
                        Text(simpleFrequency.formatted)
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
                updateValue(with: newValue)
            }
        }
    }

    init(viewModel: FormFieldViewModel<MedicationFrequency?>) {
        self.viewModel = viewModel
        simpleFrequency = viewModel.value?.simpleFrequency ?? .predefined
        times = viewModel.value?.interval ?? 1
        period = viewModel.value?.timePeriod ?? .hour
        schedule = .bid
    }

    private var shouldDisplayClearButton: Bool {
        if viewModel.isReadOnly {
            return false
        }

        return viewModel.value != nil
    }

    private func updateValue(with simpleFrequency: MedicationFrequency.SimpleFrequency) {
        switch simpleFrequency {
        case .predefined:
            viewModel.value = .predefined(schedule: schedule)
        case .timesPerPeriod:
            viewModel.value = .timesPerPeriod(times: times, period: period)
        case .everyPeriod:
            viewModel.value = .everyPeriod(interval: times, period: period)
        }
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
                ForEach(1 ..< 100) { number in
                    Text(number.formatted())
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            Picker("Period", selection: $period) {
                ForEach(MedicationFrequency.TimePeriod.allCases, id: \.self) { schedule in
                    Text(schedule.formatted)
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
                ForEach(1 ..< 100) { number in
                    Text(number.formatted())
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            Text("times per")
            Picker("Period", selection: $period) {
                ForEach(MedicationFrequency.TimePeriod.allCases, id: \.self) { schedule in
                    Text(schedule.formatted)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

#Preview {
    @Previewable @State var viewModel = FormFieldViewModel(
        value: MedicationFrequency?.none,
        title: "Take"
    )
    Form {
        MedicationFrequencyPicker(viewModel: viewModel)
    }
}
