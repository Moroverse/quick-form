// ValueEditor.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

public protocol ValueEditor<Value> {
    associatedtype Value
    var value: Value { get set }
}
