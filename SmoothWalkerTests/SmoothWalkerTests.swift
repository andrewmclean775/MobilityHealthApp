import XCTest
@testable import SmoothWalker


final class SmoothWalkerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStartDateRangeVariant() throws {
        let dailyStartDate = getStartDate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .DAILY(7))
        XCTAssert(dailyStartDate == Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 9)))
        
        let weeklyStartDate = getStartDate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .WEEKLY(3))
        XCTAssert(weeklyStartDate == Calendar.current.date(from: DateComponents(year: 2023, month: 2, day: 26)))
        
        let monthlyStartDate = getStartDate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .MONTHLY(2))
        XCTAssert(monthlyStartDate == Calendar.current.date(from: DateComponents(year: 2023, month: 2, day: 1)))
        
        let yearlyStartDate = getStartDate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .YEARLY(2))
        XCTAssert(yearlyStartDate == Calendar.current.date(from: DateComponents(year: 2022, month: 1, day: 1)))
    }
    
    func testPredicateDateRangeVariant() throws {
        let dailyPredicate = createPredicate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .DAILY(7))
        XCTAssert(dailyPredicate.predicate.predicateFormat == "endDate >= CAST(699993000.000000, \"NSDate\") AND startDate < CAST(700511400.000000, \"NSDate\") AND offsetFromStartDate >= CAST(699993000.000000, \"NSDate\")")
        XCTAssert(dailyPredicate.date == DateComponents(day: 1))
        
        let weeklyPredicate = createPredicate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .WEEKLY(7))
        print(weeklyPredicate.predicate.predicateFormat)
        XCTAssert(weeklyPredicate.predicate.predicateFormat == "endDate >= CAST(696623400.000000, \"NSDate\") AND startDate < CAST(700511400.000000, \"NSDate\") AND offsetFromStartDate >= CAST(696623400.000000, \"NSDate\")")
        XCTAssert(weeklyPredicate.date == DateComponents(day: 7))
        
        let monthlyPredicate = createPredicate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .MONTHLY(7))
        print(monthlyPredicate.predicate.predicateFormat)
        XCTAssert(monthlyPredicate.predicate.predicateFormat == "endDate >= CAST(683663400.000000, \"NSDate\") AND startDate < CAST(700511400.000000, \"NSDate\") AND offsetFromStartDate >= CAST(683663400.000000, \"NSDate\")")
        XCTAssert(monthlyPredicate.date == DateComponents(month: 1))
        
        let yearlyPredicate = createPredicate(from: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!, variant: .YEARLY(7))
        print(yearlyPredicate.predicate.predicateFormat)
        XCTAssert(yearlyPredicate.predicate.predicateFormat == "endDate >= CAST(504901800.000000, \"NSDate\") AND startDate < CAST(700511400.000000, \"NSDate\") AND offsetFromStartDate >= CAST(504901800.000000, \"NSDate\")")
        XCTAssert(yearlyPredicate.date == DateComponents(year: 1))
    
    }

}
