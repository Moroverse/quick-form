// SceneDelegate.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-02-15 16:05 GMT.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window

        // MARK: - Main Flow Assembly
    }
}
