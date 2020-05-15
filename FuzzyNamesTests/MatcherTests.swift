//
//  PersonTests.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import XCTest
@testable import FuzzyNames

class MatcherTests: XCTestCase {
    private var subject: Matcher?

    override func setUp() {
        super.setUp()
        subject = Matcher(people: TestData.real)
    }

    func testAllMatches() {
        TestData.fuzzy.enumerated().forEach { index, fuzzy in
            XCTAssertEqual(subject?.match(person: fuzzy), TestData.real[index])
        }
    }
}
