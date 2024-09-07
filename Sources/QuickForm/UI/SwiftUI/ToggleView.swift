//
//  ToggleView.swift
//
//
//  Created by Daliborka Randjelovic on 7.2.23..
//

import SwiftUI

public struct ToggleView: View {
    @Bindable private var viewModel: PropertyViewModel<Bool>

    public var body: some View {
        Toggle(viewModel.title, isOn: $viewModel.value)
            .font(.headline)
            .disabled(viewModel.isReadOnly)
    }

    public init(_ viewModel: PropertyViewModel<Bool>) {
        self.viewModel = viewModel
    }
}

struct ToggleView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var viewModel = PropertyViewModel(
            value: false,
            title: "Established",
            isReadOnly: false
        )

        var body: some View {
            ToggleView(viewModel)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
