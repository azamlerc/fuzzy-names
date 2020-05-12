//
//  PersonTests.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import XCTest
@testable import FuzzyNames

class PersonTests: XCTestCase {
    private let saurabh = Person(firstName: "Saurabh", lastName: "Shah")
    private let andrew = Person(firstName: "Andrew", lastName: "Zamler-Carhart")
    private let yao = Person(firstName: "Yao (丁尧)", lastName: "Ding")
    private let sam = Person(firstName: "Samantha", lastName: "Grone, Esq.")

    func testSimpleFirst() {
        XCTAssertEqual(saurabh.simpleFirst, "saurabh")
        XCTAssertEqual(andrew.simpleFirst, "andrew")
        XCTAssertEqual(yao.simpleFirst, "yao 丁尧")
        XCTAssertEqual(sam.simpleFirst, "samantha")
    }

    func testSimpleLast() {
        XCTAssertEqual(saurabh.simpleLast, "shah")
        XCTAssertEqual(andrew.simpleLast, "zamler carhart")
        XCTAssertEqual(yao.simpleLast, "ding")
        XCTAssertEqual(sam.simpleLast, "grone")
    }

    func testSimpleFull() {
        XCTAssertEqual(saurabh.simpleFull, "saurabhshah")
        XCTAssertEqual(andrew.simpleFull, "andrewzamlercarhart")
        XCTAssertEqual(yao.simpleFull, "yao丁尧ding")
        XCTAssertEqual(sam.simpleFull, "samanthagrone")
    }
}
