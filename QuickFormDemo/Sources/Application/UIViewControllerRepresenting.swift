//
//  UIViewControllerRepresenting.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 28.9.24..
//

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
