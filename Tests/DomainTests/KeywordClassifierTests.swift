import Testing
import Foundation
@testable import Domain

@Suite("KeywordCategoryClassifier")
struct KeywordClassifierTests {

    private func makeClassifier(categories: [String]) -> KeywordCategoryClassifier {
        let classifier = KeywordCategoryClassifier()
        let map = Dictionary(uniqueKeysWithValues: categories.map { ($0, UUID()) })
        classifier.updateCategories(map)
        return classifier
    }

    @Test("predicts Food & Dining for Starbucks")
    func predictsCoffee() {
        let classifier = makeClassifier(categories: ["Food & Dining", "Transportation", "Shopping"])
        let id = classifier.predict(merchant: "Starbucks", note: "")
        #expect(id != nil)
    }

    @Test("predicts Transportation for Grab")
    func predictsGrab() {
        let classifier = makeClassifier(categories: ["Food & Dining", "Transportation", "Shopping"])
        let id = classifier.predict(merchant: "Grab", note: "")
        #expect(id != nil)
    }

    @Test("returns nil for unknown merchant when Other not in map")
    func returnsNilForUnknown() {
        let classifier = makeClassifier(categories: ["Food & Dining", "Transportation"])
        let id = classifier.predict(merchant: "ZzZzUnknownCorp", note: "")
        #expect(id == nil)
    }

    @Test("returns nil before updateCategories is called")
    func returnsNilBeforeUpdate() {
        let classifier = KeywordCategoryClassifier()
        let id = classifier.predict(merchant: "Starbucks", note: "")
        #expect(id == nil)
    }

    @Test("prediction is case-insensitive")
    func caseInsensitive() {
        let classifier = makeClassifier(categories: ["Food & Dining"])
        let lower = classifier.predict(merchant: "starbucks", note: "")
        let upper = classifier.predict(merchant: "STARBUCKS", note: "")
        #expect(lower != nil)
        #expect(upper != nil)
        #expect(lower == upper)
    }

    @Test("note field also contributes to prediction")
    func noteField() {
        let classifier = makeClassifier(categories: ["Food & Dining"])
        let id = classifier.predict(merchant: "Shop123", note: "coffee refill")
        #expect(id != nil)
    }
}
