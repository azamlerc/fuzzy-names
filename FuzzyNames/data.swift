//
//  data.swift
//  FuzzyNames
//
//  Created by Andrew Zamler-Carhart on 3/5/20.
//  Copyright © 2020 Andrew Zamler-Carhart. All rights reserved.
//

import Foundation

let sourceNames = [
    ["id": "100", "first": "Saurabh", "last": "Shah"],
    ["id": "101", "first": "Andrew", "last": "Zamler-Carhart"],
    ["id": "102", "first": "Cheuk Kwan", "last": "Chan"],
    ["id": "103", "first": "Theo", "last": "Rose"],
    ["id": "104", "first": "Yvonne", "last": "Wang"],
    ["id": "105", "first": "Henry E.", "last": "Warren"],
    ["id": "106", "first": "Alice", "last": "Yoon"],
    ["id": "107", "first": "bart", "last": "karmilowicz"],
    ["id": "108", "first": "Angel", "last": "Dionisio"],
    ["id": "109", "first": "Yao (丁尧)", "last": "Ding"],
    ["id": "110", "first": "Evan", "last": "Compton"],
    ["id": "111", "first": "Sam", "last": "Grone"],
    ["id": "112", "first": "Masha", "last": "Malygina"],
    ["id": "113", "first": "Ronny", "last": "Peña"],
]

let targetNames = [
    ["id": "1000", "first": "Saurabh", "last": "Shah"],
    ["id": "1001", "first": "Andrew", "last": "Zamler Carhart"], // hyphen
    ["id": "1002", "first": "Cheuk", "last": "Kwan Chan"], // three names
    ["id": "1003", "first": "Theodore", "last": "Rose"], // nickname
    ["id": "1004", "first": "YVONNE", "last": "WANG"], // uppercase
    ["id": "1005", "first": "Henry", "last": "E. Warren"], // initial in last
    ["id": "1006", "first": "Alice (미선)", "last": "Yoon"], // alternate name
    ["id": "1007", "first": "Bartłomiej", "last": "Karmilowicz"], // nickname, lowercase, special chars
    ["id": "1008", "first": "Angel Anibal", "last": "Dionisio Castillo"], // extra words in target
    ["id": "1009", "first": "Yao", "last": "Ding"], // extra words in source
    ["id": "1010", "first": "Evan B.", "last": "Compton"], // initial
    ["id": "1011", "first": "Samantha", "last": "Grone, Esq."], // nickname, suffix
    ["id": "1012", "first": "Maria", "last": "Malygina, PhD"], // nickname
    ["id": "1013", "first": "Ronald", "last": "Pena"], // nickname, special chars
]
