//
//  main.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import Foundation

let sourcePeople = sourceNames.map { Person(data: $0) }
let targetPeople = targetNames.map { Person(data: $0) }

var firstIndex = [String:[Person]]()
var lastIndex = [String:[Person]]()
var fullIndex = [String:[Person]]()

for target in targetPeople {
    addToIndex(key: target.simpleFirst, person: target, index: &firstIndex)
    addToIndex(key: target.simpleLast, person: target, index: &lastIndex)
    addToIndex(key: target.simpleFull, person: target, index: &fullIndex)

    if target.simpleFirst.contains(" ") || target.simpleLast.contains(" ") {
        for first in target.simpleFirst.components(separatedBy: " ") {
            for last in target.simpleLast.components(separatedBy: " ") {
                addToIndex(key: first + last, person: target, index: &fullIndex)
            }
        }
    }
}

func matchPerson(source: Person) -> Person? {
    if let results = fullIndex[source.simpleFull] {
        return results[0]
    }

    if source.simpleFirst.contains(" ") || source.simpleLast.contains(" ") {
        for first in nameVariations(name: source.simpleFirst) {
            for last in nameVariations(name: source.simpleLast) {
                if let results = fullIndex[first + last] {
                    return results[0]
                }
            }
        }
    }

    if let lastMatches = lastIndex[source.simpleLast],
        let nicknames = getNicknames(value: source.simpleFirst),
        let firstMatches = findPeople(nicknames: nicknames)
    {
        let results = firstMatches.filter(lastMatches.contains)
        if results.count == 1 {
            return results[0]
        }
    }

    return nil
}

var matched = 0
var total = 0

for source in sourcePeople {
    if let target = matchPerson(source: source) {
        source.matchedPerson = target
        matched += 1
        print("\(source.firstName) / \(source.lastName) = \(target.firstName) / \(target.lastName)")
    } else {
        print("no match for \(source.firstName) \(source.lastName)")
    }
    total += 1
}

print("\nmatched \(matched) of \(total)\n")
