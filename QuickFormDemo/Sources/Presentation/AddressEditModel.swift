// AddressEditModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

import Observation
@preconcurrency import QuickForm

@QuickForm(Address.self)
class AddressEditModel {
    @PropertyEditor(keyPath: \Address.line1)
    var line1 = FormFieldViewModel(value: String?.none, title: "Address Line 1")
}
