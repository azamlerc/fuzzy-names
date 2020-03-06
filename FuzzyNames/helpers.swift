//
//  helpers.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import Foundation

func addToIndex(key: String, person: Person, index: inout [String:[Person]]) {
    if let people = index[key] {
        var newPeople = people
        newPeople.append(person)
        index[key] = newPeople
    } else {
        index[key] = [person]
    }
}

func getNicknames(value: String) -> [String]? {
    for nicks in nicknames {
        if nicks.contains(value) {
            return nicks
        }
    }
    return nil
}

func findPeople(nicknames: [String]) -> [Person]? {
    var people = [Person]()
    for nick in nicknames {
        if let found = firstIndex[nick] {
            people.append(contentsOf: found)
        }
    }
    return people.count > 0 ? people : nil
}

func nameVariations(name: String) -> [String] {
    if name.contains(" ") {
        var names = [name.replacingOccurrences(of: " ", with: "")]
        names.append(contentsOf: name.components(separatedBy: " ").filter { $0.count > 1 })
        return names
    } else {
        return [name]
    }
}
