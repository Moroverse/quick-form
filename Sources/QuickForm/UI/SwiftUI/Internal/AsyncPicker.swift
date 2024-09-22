// AsyncPicker.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-15 18:18 GMT.

import SwiftUI

struct AsyncPicker<Model: RandomAccessCollection, Query, Content>: View
    where Model: Sendable, Model.Element: Identifiable, Query: Sendable & Equatable, Content: View {
    private let valuesProvider: (Query) async throws -> Model
    private let queryBuilder: (String) -> Query
    private let content: (Model.Element) -> Content
    @State private var searchText: String
    @State private var query: Query?
    @State private var model: ModelState<Model>
    @State private var selectedID: Model.Element.ID?
    @Binding private var selectedValue: Model.Element?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch model {
            case .loading:
                ContentUnavailableView {
                    VStack {
                        ProgressView()
                        Text("Loading...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

            case let .loaded(values):
                if values.isEmpty {
                    ContentUnavailableView.search
                } else {
                    List(selection: $selectedID) {
                        ForEach(values) { value in
                            content(value)
                                .tag(value.id)
                        }
                    }
                    .listStyle(.plain)
                }

            case .initial:
                ContentUnavailableView.search

            case let .error(error):
                ContentUnavailableView(
                    "Error",
                    image: "",
                    description: Text("Error loading content: \(error.localizedDescription)")
                )
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newSearchText in
            query = queryBuilder(newSearchText)
        }
        .onChange(of: selectedID) { _, newQuery in
            if case let .loaded(values) = model, let selectedID = newQuery {
                if let selectedValue = values.first(where: {
                    $0.id == selectedID
                }) {
                    self.selectedValue = selectedValue
                    dismiss()
                }
            }
        }
        .onAppear {
            query = queryBuilder(searchText)
        }
        .task(id: query) {
            if let query {
                model = .loading
                do {
                    let model = try await valuesProvider(query)
                    self.model = .loaded(model)
                } catch _ as CancellationError {
                } catch {
                    model = .error(error)
                }
            }
        }
    }

    init(
        selectedValue: Binding<Model.Element?>,
        valuesProvider: @escaping (Query) async throws -> Model,
        queryBuilder: @escaping (String) -> Query,
        content: @escaping (Model.Element) -> Content
    ) {
        _selectedValue = selectedValue
        self.valuesProvider = valuesProvider
        self.queryBuilder = queryBuilder
        self.content = content
        searchText = ""
        query = nil
        model = .initial
    }
}

struct Weekday: Identifiable, Hashable {
    let id: Int
    let name: String
}

#Preview {
    NavigationStack {
        AsyncPicker(
            selectedValue: .constant(nil),
            valuesProvider: { query in
                let weekdays = [
                    Weekday(id: 1, name: "Monday"),
                    Weekday(id: 2, name: "Tuesday"),
                    Weekday(id: 3, name: "Wednesday"),
                    Weekday(id: 4, name: "Thursday"),
                    Weekday(id: 5, name: "Friday"),
                    Weekday(id: 6, name: "Saturday"),
                    Weekday(id: 7, name: "Sunday")
                ]
                try await Task.sleep(for: .seconds(3))
                if query.isEmpty {
                    return weekdays
                } else {
                    return weekdays.filter {
                        $0.name.lowercased().contains(query.lowercased())
                    }
                }
            },
            queryBuilder: { text in
                text
            },
            content: { item in
                Text(item.name)
            }
        )
    }
}
