// String+Scripts.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-28 05:15 GMT.

public extension String {
    static func lintScript() -> String {
        """
        #!/bin/bash
        export PATH="$PATH:$HOME/.local/share/mise/shims"

        if which swiftformat > /dev/null; then
            swiftformat . --lint
        else
            echo "warning: SwiftFormat not installed, run mise install"
        fi

        if which swiftlint > /dev/null; then
            swiftlint
        else
            echo "warning: SwiftLint not installed, run mise install"
        fi
        """
    }
}
