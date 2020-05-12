//
//  Person.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import Foundation

class Person {
    let firstName: String
    let lastName: String

    var simpleFirst: String {
        return simplify(name: firstName)
    }

    var simpleLast: String {
        return simplify(name: lastName)
    }

    var simpleFull: String {
        return "\(simpleFirst)\(simpleLast)".replacingOccurrences(of: " ", with: "")
    }

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }

    private func simplify(name: String) -> String {
        let punctuation = [".", ",", "(", ")", "|"]
        let substitutions = ["-": " ", "ł": "l"]
        let suffixes = ["Esq", "JD", "MBA", "PA", "PhD", "Jr", "II", "III"].map { " " + $0.lowercased() }

        var simple = name.lowercased().folding(options: .diacriticInsensitive, locale: .current)

        punctuation.filter { p in simple.contains(p) }
            .forEach { p in simple = simple.replacingOccurrences(of: p, with: "") }

        substitutions.filter { k, _ in simple.contains(k) }
            .forEach { k, v in simple = simple.replacingOccurrences(of: k, with: v) }

        suffixes.filter { s in simple.hasSuffix(s) }
            .forEach { simple = simple.replacingOccurrences(of: $0, with: "") }

        return simple
    }
}

extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    }
}
