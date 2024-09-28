// QuickFormDemoApp.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 17:09 GMT.

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
