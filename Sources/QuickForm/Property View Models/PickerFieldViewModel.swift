//
//  PickerFieldViewModel.swift
//  quick-form
//
//  Created by Daniel Moro on 7.9.24..
//

import Observation
@Observable
public final class PickerFieldViewModel<Property: Hashable & CustomStringConvertible>: ValueEditor {
    public var title: String
    public var allValues: [Property]
    public var value: Property
    public var isReadOnly: Bool

    public init(
        value: Property,
        allValues: [Property],
        title: String = "",
        isReadOnly: Bool = false
    ) {
        self.value = value
        self.allValues = allValues
        self.title = title
        self.isReadOnly = isReadOnly
    }
}
