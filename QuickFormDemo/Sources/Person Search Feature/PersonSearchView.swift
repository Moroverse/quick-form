//
//  PersonSearchView.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 8.9.24..
//

import SwiftUI

struct PersonSearchViewDelegate {
    var didSelectPerson: ((PersonInfo) -> Void)?
}

enum PersonSearch {
    @MainActor
    static func personSearch(delegate: PersonSearchViewDelegate) -> UIViewController {
        let controller = UIHostingController(rootView: PersonSearchView(people: people, delegate: delegate))
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .formSheet
        return navigationController
    }
}

let people = [
    PersonInfo(id: 1, name: "John Smith"),
    PersonInfo(id: 2, name: "Emma Johnson"),
    PersonInfo(id: 3, name: "Michael Davis"),
    PersonInfo(id: 4, name: "Sophia Rodriguez"),
    PersonInfo(id: 5, name: "William Chen"),
    PersonInfo(id: 6, name: "Olivia Taylor"),
    PersonInfo(id: 7, name: "James Brown"),
    PersonInfo(id: 8, name: "Ava Martinez"),
    PersonInfo(id: 9, name: "Robert Lee"),
    PersonInfo(id: 10, name: "Isabella Kim"),
    PersonInfo(id: 11, name: "David Wilson"),
    PersonInfo(id: 12, name: "Mia Nguyen"),
    PersonInfo(id: 13, name: "Daniel Garcia"),
    PersonInfo(id: 14, name: "Emily Patel"),
    PersonInfo(id: 15, name: "Joseph Anderson"),
    PersonInfo(id: 16, name: "Sophie Müller"),
    PersonInfo(id: 17, name: "Alexander Wong"),
    PersonInfo(id: 18, name: "Chloe O'Brien"),
    PersonInfo(id: 19, name: "Benjamin Cohen"),
    PersonInfo(id: 20, name: "Zoe van der Berg")
]

struct PersonSearchView: View {
    let people: [PersonInfo]
    let delegate: PersonSearchViewDelegate?
    @State var searchText = ""
    @State var selectedID: Int?

    var filteredPeople: [PersonInfo] {
        if self.searchText.isEmpty {
            return people
        }
        return people.filter { person in
            person.name.lowercased().contains(searchText.lowercased())
        }
    }

    init(people: [PersonInfo], delegate: PersonSearchViewDelegate? = nil) {
        self.people = people
        self.delegate = delegate
    }
    var body: some View {
        List(selection: $selectedID) {
            ForEach(filteredPeople) { person in
                Text(person.name)
            }
        }
        .searchable(text: $searchText)
        .listStyle(.plain)
        .onChange(of: selectedID) { _, newValue in
            if let newValue, let delegate {
                if let selected = people.first(where: { $0.id == newValue }) {
                    delegate.didSelectPerson?(selected)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PersonSearchView(people: people)
    }
}
