# Fuzzy Name Matching

Identifying the same people in different databases can be a tricky problem. In an ideal world, people would all have a unique identifier that we could use to join records across databases. However, when this is not available, it may be necessary to try to use people’s names for matching. As it turns out, people’s names can be messy, and are less suitable for use as unique identifiers than you might hope. Some issues that lead to complication are:

* Initials
* Suffixes (III, Jr. etc.)
* Diacritical marks
* Capitalization
* Middle names
* Hyphenated names
* Multiple first or last names
* Nicknames

### Why do we need this? 

At Compass, most of our real estate agents have one or more memberships in what is called a Multiple Listing Service, or MLS (a company that acts as a data source for real estate listings in a given area). For a variety of reasons, we need to identify records for our agents in these systems. In many cases, it’s possible to match agents using their work email address, personal email address, or their state real estate license number. However, about half of the time matching by name is the most reliable solution. 

### Efficiency 

A simple approach would be to write a function that takes two names and returns whether they are considered a match. However, when looking for a few thousand people in a few million records, that becomes a problem of n-squared complexity (a few billion comparisons). Instead, the problem can be optimized by indexing the target records. In some cases, it may be necessary to add several variations of a given person’s name to the index. 

### Reliability

Matching by name using these techniques may produce duplicate records. If one record is found we have a relatively high degree of confidence in a match, but if multiple records are found there is a risk of false positives. Therefore it’s a good idea to start with the most exact matching techniques, which tend to produce fewer results, then proceed to the fuzzier ones.  

### Nicknames 

It’s surprisingly common for people to use variations on a name in different systems. For example, someone may prefer to use a nickname like `Dave` as part of their public facing brand, while using their legal name `David` for official purposes. For our program, these need to be considered equivalent.

Some names have quite a number of variations, like `Alexander`, `Alexandra`, `Alex`, `Alejandro`, `Ali`, and `Sasha`. We started with a list of common nicknames, and expanded it by training the system using people matched by other means such as email. In this way we empirically found no fewer than twenty variations of `Catherine`, `Katherine`, `Kathryn`, `Cathy`, `Katie`, `Kate`, etc.

### Sample code

The sample code for this article is based on a script written in Swift. If you have a Mac, you can download the [source code](https://github.com/azamlerc/fuzzy-names) and run the script in Xcode.

## Algorithm

### Simple name

First, we will need a function that can perform a few basic operations to simplify a first or last name. These operations are considered non-destructive and unlikely to lead to false positives. The process includes:

* make the name lowercase
* remove diacritical marks, for example `é` → `e`
* remove punctuation such as periods, commas and parentheses
* replace hyphens with spaces, so a hyphenated name is equivalent to a double name
* remove common suffixes like `Jr` and `Esq`

```
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
```
For your purposes, it may be helpful to add other punctuation, substitutions or suffixes that you may encounter. For example, Swift did not perform `ł` → `l` when removing diacritical marks so this was added manually.

### Person class

For this exercise we’ll use a very simple class called Person. Every person will have an first and last name. In addition, we’ll have some computed properties: simple versions of the first and last name, and a single full name string based on the simple first and last names with all the spaces removed.

```
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
}
```
For this simple example, we’ll use the same Person class for both the source and target data. In other cases, it may make more sense for them to be different classes, especially if they are stored in different database systems.

### Indexing

For all the people in our source list, we will try to find matching people in the target list. It is expected that the target list may be orders of magnitude larger than the source list, so we will index it first for efficiency. 

We’ll index all the target people using three dictionaries, mapping first, last and full names to arrays of people who have them. 

In addition, if a target person has multiple first and/or last names, we’ll add every possible combination of any first name with any last name to the full name index. It’s not a problem to add the same person to the index multiple times. 
```
class Matcher {
    private let people: [Person]

    private var firstIndex: [String: [Person]] = [:]
    private var lastIndex: [String: [Person]] = [:]
    private var fullIndex: [String: [Person]] = [:]

    init(people: [Person]) {
        self.people = people
        buildIndexes()
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
}
```

### Match function

Given a source person, here’s a function that will look them up in the indexes using a few different techniques, and return a result if found. 

The first approach is to look for an exact match in the full name index. This uses the simplified names, so capitalization, punctuation, diacritical marks, suffixes etc. are not an issue. Whether a middle name is added to the first or last name field is also not a concern in this case. 

If the source person’s first or last name contain multiple words, we’ll try looking up every possible combination of first and last names in the full name index. Note that initials are ignored, so `Alice B.` and `Evan B.` will not be considered a match.

Finally, we’ll try matching using nicknames. We’ll look for all people with the same last name, check if there are nicknames of the person’s frst name, and look for all people with any of those as first names. Then we’ll just take the intersection of those two lists to get the results.  

```
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
```

Testing the match function is as simple as:
```
enum TestData {
    static var real: [Person] {
        return [
            Person(firstName: "Saurabh", lastName: "Shah"),
            Person(firstName: "Andrew", lastName: "Zamler Carhart"),
            Person(firstName: "Cheuk", lastName: "Kwan Chan"),
            Person(firstName: "Alice (미선)", lastName: "Yoon"),
            Person(firstName: "Samantha", lastName: "Grone, Esq."),
        ]
    }

    static var fuzzy: [Person] {
        return [
            Person(firstName: "Saurabh", lastName: "Shah"),
            Person(firstName: "Andrew", lastName: "Zamler-Carhart"),
            Person(firstName: "Cheuk Kwan", lastName: "Chan"),
            Person(firstName: "Alice", lastName: "Yoon"),
            Person(firstName: "Sam", lastName: "Grone"),
        ]
    }
}

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
```

## Examples

Here are a few examples used for unit testing, with notes on how they passed.

`Saurabh / Shah = Saurabh / Shah`

An exact match!

`Andrew / Zamler-Carhart = Andrew / Zamler Carhart`

Hyphens are converted to spaces. This is a full name match.

`Cheuk Kwan / Chan = Cheuk / Kwan Chan`

This is a compound first name, but the second part of the first name is added to the last name field in the target system. This is matched by full name.

`Henry E. / Warren = Henry / E. Warren`

A middle initial added in different places is still a full name match.

`Evan / Compton = Evan B. / Compton`

When searching for name variations, initials are ignored.

`Yvonne / Wang = YVONNE / WANG`

Matching is case insentitive.

`Alice / Yoon = Alice (미선) / Yoon`

A name in a different alphabet. The parentheses are ignored, and the name is indexed using either or both first names.

`Yao (丁尧) / Ding = Yao / Ding`

Similar situation, but with the extra name in the source data instead of the target data. The index is queried using either or both first names.  

`Angel / Dionisio = Angel Anibal / Dionisio Castillo`

Matching words in compound first and last names.

`Theo / Rose = Theodore / Rose`

Matched by nickname.

`bart / karmilowicz = Bartłomiej / Karmilowicz`

Combination of case insensitive matching, manually replacing special characters, and using nicknames. 

`Sam / Grone = Samantha / Grone, Esq.`

Combination of using nickname, removing punctuation and ignoring suffix.

`Masha / Malygina = Maria / Malygina, PhD`

Combination of using nickname, removing punctuation and ignoring suffix.

`Ronny / Peña = Ronald / Pena`

Combination of using nickname and automatically removing diacritical marks.










