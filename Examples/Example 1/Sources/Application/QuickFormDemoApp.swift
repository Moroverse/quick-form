// QuickFormDemoApp.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

import QuickForm
import SwiftUI

@MainActor
func initialController() -> UIViewController {
    MainViewController(nibName: nil, bundle: nil)
}

@main
struct QuickFormDemoApp: App {
    @State var controller = initialController()
    var body: some Scene {
        WindowGroup {
            UIViewControllerRepresenting {
                controller
            }
        }
    }
}
