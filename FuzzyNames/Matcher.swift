//
//  Matcher.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import Foundation

class Matcher {
    private let people: [Person]

    private var firstIndex: [String: [Person]] = [:]
    private var lastIndex: [String: [Person]] = [:]
    private var fullIndex: [String: [Person]] = [:]

    init(people: [Person]) {
        self.people = people
        buildIndexes()
    }

    func match(person: Person) -> Person? {
        if let match = fullIndex[person.simpleFull]?.first {
            return match
        }

        if person.simpleFirst.contains(" ") || person.simpleLast.contains(" ") {
            for first in variations(name: person.simpleFirst) {
                for last in variations(name: person.simpleLast) {
                    if let person = fullIndex[first + last]?.first {
                        return person
                    }
                }
            }
        }

        return matchingNicknames(person: person)?.first
    }

    private func buildIndexes() {
        people.forEach { person in
            firstIndex[person.simpleFirst, default: []].append(person)
            lastIndex[person.simpleLast, default: []].append(person)
            fullIndex[person.simpleFull, default: []].append(person)

            guard person.simpleFirst.contains(" ") || person.simpleLast.contains(" ") else {
                return
            }

            person.simpleFirst.components(separatedBy: " ").forEach { first in
                person.simpleLast.components(separatedBy: " ").forEach { last in
                    fullIndex[first + last, default: []].append(person)
                }
            }
        }
    }

    private func variations(name: String) -> [String] {
        guard name.contains(" ") else {
            return [name]
        }

        var names = [name.replacingOccurrences(of: " ", with: "")]
        names.append(contentsOf: name.components(separatedBy: " ").filter { $0.count > 1 })
        return names
    }

    func matchingNicknames(person: Person) -> [Person]? {
        guard let lastMatches = lastIndex[person.simpleLast],
            let nicknames = Nicknames.all.first(where: { $0.contains(person.simpleFirst) }) else {
            return nil
        }

        let matches = nicknames.flatMap { firstIndex[$0] ?? [] }
        return matches.filter(lastMatches.contains)
    }
}
