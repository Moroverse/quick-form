// Assessment.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-28 10:01 GMT.

final class Assessment: Identifiable {
    var name: String
    var id: Int

    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
}

extension Assessment: CustomStringConvertible {
    var description: String {
        name
    }
}

extension Assessment: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Assessment, rhs: Assessment) -> Bool {
        lhs.id == rhs.id
    }
}
