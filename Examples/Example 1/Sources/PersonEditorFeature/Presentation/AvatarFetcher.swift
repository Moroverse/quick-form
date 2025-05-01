// AvatarFetcher.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-15 16:46 GMT.

final class AvatarFetcher {
    static let shared = AvatarFetcher()

    func fetchAvatar(query: String) async throws -> [Avatar] {
        let list = [
            Avatar(id: 1, imageName: "person1"),
            Avatar(id: 2, imageName: "person2"),
            Avatar(id: 3, imageName: "person3"),
            Avatar(id: 4, imageName: "person4"),
            Avatar(id: 5, imageName: "person5")
        ]
        try await Task.sleep(for: .seconds(1))
        if query.isEmpty {
            return list
        } else {
            return list.filter {
                $0.imageName.contains(query)
            }
        }
    }
}
