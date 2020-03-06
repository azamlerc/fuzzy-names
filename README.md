# Fuzzy Name Matching

Identifying the same people in different databases can be a tricky problem. In an ideal world, people would all have a unique identifier that we could use to join records across databases. However, when this is not available, it may be necessary to try to use people's names for matching. As it turns out, people's names can be messy, and are less suitable for use as unique identifiers than you might hope. Some issues that lead to complication are:

* Initials
* Suffixes (III, Jr. etc.)
* Diacritical marks
* Capitalization
* Middle names
* Hyphenated names
* Multiple first or last names
* Nicknames

### Why do we need this? 

At Compass, most of our real estate agents have one or more memberships in what is called a Multiple Listing Service, or MLS (a company that acts as a data source for real estate listings in a given area). For a variety of reasons, we need to identify records for our agents in these systems. In many cases, it's possible to match agents using their work email address, personal email address, or their state real estate license number. However, about half of the time matching by name is the most reliable solution. 

### Efficiency 

A simple approach would be to write a function that takes two names and returns whether they are considered a match. However, when looking for a few thousand people in a few million records, that becomes a problem of n-squared efficiency (a few billion comparisons). Instead, the problem can be optimized by indexing the target records. In some cases, it may be necessary to add several variations of a given person's name to the index. 

### Reliability

Matching by name using these techniques may produce duplicate records. If one record is found we have a relatively high degree of confidence in a match, but if multiple records are found there is a risk of false positives. Therefore it's a good idea to start with the most exact matching techniques, which tend to produce fewer results, then proceed to the fuzzier ones.  

### Nicknames 

It's surprisingly common for people to use variations on a name in different systems. For example, someone may prefer to use a nickname like `Dave` as part of their public facing brand, while using their legal name `David` for official purposes. For our purposes, these need to be considered equivalent.

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
let punctuation = [".", ",", "(", ")", "|"]
let substitutions = ["-":" ", "ł":"l"]
let suffixes = ["Esq", "JD", "MBA", "PA", "PhD", "Jr","II", "III"].map { " " + $0.lowercased() }

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
```
For your purposes, it may be helpful to add other punctuation, substitutions or suffixes that you may encounter. For example, Swift did not perform `ł` → `l` when removing diacritical marks so this was added manually.

### Person class

For this exercise we'll use a very simple class called Person. Every person will have an id, first name and last name. In addition, we'll store some derived values: simple versions of the first and last name, and a single full name string based on the simple first and last names with all the spaces removed.

```
class Person: Equatable {
    let id: String
    let firstName: String
    let lastName: String

    let simpleFirst: String
    let simpleLast: String
    let simpleFull: String

    init(id: String, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName

        self.simpleFirst = simple(name: firstName)
        self.simpleLast = simple(name: lastName)
        self.simpleFull = (simpleFirst + simpleLast).replacingOccurrences(of: " ", with: "")
    }
}
```
For this simple example, we'll use the same Person class for both the source and target data. In other cases, it may make more sense for them to be different classes, especially if they are stored in different databsae systems.

### Indexing

For all the people in our source list, we will try to find matching people in the target list. It is expected that the target list may be orders of magnitude larger than the source list, so we will index it first for efficiency. 

We'll index all the target people using three dictionaries, mapping first, last and full names to arrays of people who have them. 

In addition, if a target person has multiple first and/or last names, we'll add every possible combination of any fist name with any last name to the full name index. There's no reason why we can't add the same person to the index multiple times. 
```
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
```

### Match function

Given a source person, here's a function that will look them up in the indexes using a few different techniques, and return a result if found. 

The first approach is to look for an exact match in the full name index. This uses the simplified names, so capitalization, punctuation, diacritical marks, suffixes etc. are not an issue. Whether a middle name is added to the first or last name field is also not a concern in this case. 

If the source person's first or last name contain multiple words, we'll try looking up every possible combination of first and last names in the full name index. Note that initials are ignored. 

Finally, we'll try matching using nicknames. We'll look for all people with the same last name, check if there are nicknames of the person's frst name, and look for all people with any of those as first names. Then we'll just take the intersection of those two lists and those are the results.  

```
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
```

Calling the match function is as simple as:
```
for source in sourcePeople {
    if let target = matchPerson(source: source) {
        source.matchedPerson = target
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

`Yao (丁堯) / Ding = Yao / Ding`

Same principle, but with the extra name in the source data instead of the target data. The index is queried using either or both first names.  

`Angel / Dionisio = Angel Anibal / Dionisio Castillo`

Matching words in compound first and last names.

`Theo / Rose = Theodore / Rose`

Matched by nickname.

`bart / karmilowicz = Bartłomiej / Karmilowicz`

Combination of case insensitive matching, man0ually replacing special characters, and using nicknames. 

`Sam / Grone = Samantha / Grone, Esq.`

Combinatin of using nickname, removing punctuation and ignoring suffix.

`Masha / Malygina = Maria / Malygina, PhD`

Combinatin of using nickname, removing punctuation and ignoring suffix.

`Ronny / Peña = Ronald / Pena`

Combination of using nickname and automatically removing diacritical marks.










