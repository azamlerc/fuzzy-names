//
//  person.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import Foundation

class Person: Equatable {
    let id: String
    let firstName: String
    let lastName: String

    let simpleFirst: String
    let simpleLast: String
    let simpleFull: String

    var matchedPerson: Person?

    init(id: String, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName

        self.simpleFirst = simple(name: firstName)
        self.simpleLast = simple(name: lastName)
        self.simpleFull = (simpleFirst + simpleLast).replacingOccurrences(of: " ", with: "")
    }

    convenience init(data: [String:String]) {
        self.init(id: data["id"]!, firstName: data["first"]!, lastName: data["last"]!)
    }

    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
}

func simple(name: String) -> String {
    var simple = name
        .lowercased()
        .folding(options: .diacriticInsensitive, locale: .current)

    for value in punctuation {
        if simple.contains(value) {
            simple = simple.replacingOccurrences(of: value, with: "")
        }
    }

    for (before,after) in substitutions {
        if simple.contains(before) {
            simple = simple.replacingOccurrences(of: before, with: after)
        }
    }

    for suffix in suffixes {
        if simple.hasSuffix(suffix) {
            simple = simple.replacingOccurrences(of: suffix, with: "")
        }
    }
    return simple
}
