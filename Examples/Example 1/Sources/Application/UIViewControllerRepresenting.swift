// UIViewControllerRepresenting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-28 04:57 GMT.

import SwiftUI
import UIKit

public struct UIViewControllerRepresenting<
    UIViewControllerType: UIViewController
>: UIViewControllerRepresentable {
    private let base: UIViewControllerType
    public init(_ base: () -> UIViewControllerType) {
        self.base = base()
    }

    public func makeUIViewController(context _: Context) -> UIViewControllerType { base }
    public func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
