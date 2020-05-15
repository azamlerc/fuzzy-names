//
//  TestData.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import Foundation
@testable import FuzzyNames

enum TestData {
    static var real: [Person] {
        return [
            Person(firstName: "Saurabh", lastName: "Shah"),
            Person(firstName: "Andrew", lastName: "Zamler Carhart"),
            Person(firstName: "Cheuk", lastName: "Kwan Chan"),
            Person(firstName: "Theodore", lastName: "Rose"),
            Person(firstName: "YVONNE", lastName: "WANG"),
            Person(firstName: "Henry", lastName: "E. Warren"),
            Person(firstName: "Alice (미선)", lastName: "Yoon"),
            Person(firstName: "Bartłomiej", lastName: "Karmilowicz"),
            Person(firstName: "Angel Anibal", lastName: "Dionisio Castillo"),
            Person(firstName: "Yao", lastName: "Ding"),
            Person(firstName: "Evan B.", lastName: "Compton"),
            Person(firstName: "Samantha", lastName: "Grone, Esq."),
            Person(firstName: "Maria", lastName: "Malygina, PhD"),
            Person(firstName: "Ronald", lastName: "Pena")
        ]
    }

    static var fuzzy: [Person] {
        return [
            Person(firstName: "Saurabh", lastName: "Shah"),
            Person(firstName: "Andrew", lastName: "Zamler-Carhart"),
            Person(firstName: "Cheuk Kwan", lastName: "Chan"),
            Person(firstName: "Theo", lastName: "Rose"),
            Person(firstName: "Yvonne", lastName: "Wang"),
            Person(firstName: "Henry E.", lastName: "Warren"),
            Person(firstName: "Alice", lastName: "Yoon"),
            Person(firstName: "bart", lastName: "karmilowicz"),
            Person(firstName: "Angel", lastName: "Dionisio"),
            Person(firstName: "Yao (丁尧)", lastName: "Ding"),
            Person(firstName: "Evan", lastName: "Compton"),
            Person(firstName: "Sam", lastName: "Grone"),
            Person(firstName: "Masha", lastName: "Malygina"),
            Person(firstName: "Ronny", lastName: "Peña")
        ]
    }
}
