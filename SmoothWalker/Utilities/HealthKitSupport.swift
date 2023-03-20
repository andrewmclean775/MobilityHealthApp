/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection of utility functions used for general HealthKit purposes.
*/

import Foundation
import HealthKit

let WalkinsSpeedUnit = HKUnit.init(from: "m/s")

// MARK: Sample Type Identifier Support

/// Return an HKSampleType based on the input identifier that corresponds to an HKQuantityTypeIdentifier, HKCategoryTypeIdentifier
/// or other valid HealthKit identifier. Returns nil otherwise.
func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }
    
    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }
    
    return nil
}

// MARK: - Unit Support

/// Return the appropriate unit to use with an HKSample based on the identifier. Asserts for compatible units.
func preferredUnit(for sample: HKSample) -> HKUnit? {
    let unit = preferredUnit(for: sample.sampleType.identifier, sampleType: sample.sampleType)
    
    if let quantitySample = sample as? HKQuantitySample, let unit = unit {
        assert(quantitySample.quantity.is(compatibleWith: unit),
               "The preferred unit is not compatiable with this sample.")
    }
    
    return unit
}

/// Returns the appropriate unit to use with an identifier corresponding to a HealthKit data type.
func preferredUnit(for sampleIdentifier: String) -> HKUnit? {
    return preferredUnit(for: sampleIdentifier, sampleType: nil)
}

private func preferredUnit(for identifier: String, sampleType: HKSampleType? = nil) -> HKUnit? {
    var unit: HKUnit?
    let sampleType = sampleType ?? getSampleType(for: identifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
        switch quantityTypeIdentifier {
        case .stepCount:
            unit = .count()
        case .distanceWalkingRunning, .sixMinuteWalkTestDistance:
            unit = .meter()
        case .walkingSpeed:
            unit = WalkinsSpeedUnit
        default:
            break
        }
    }
    
    return unit
}

// MARK: - Query Support

/// Return an anchor date for a statistics collection query.
func createAnchorDate() -> Date {
    // Set the arbitrary anchor date to Monday at 3:00 a.m.
    let calendar: Calendar = .current
    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: Date())
    let offset = (7 + (anchorComponents.weekday ?? 0) - 2) % 7
    
    anchorComponents.day! -= offset
    anchorComponents.hour = 3
    
    let anchorDate = calendar.date(from: anchorComponents)!
    
    return anchorDate
}

/// This is commonly used for date intervals so that we get the last seven days worth of data,
/// because we assume today (`Date()`) is providing data as well.
func getLastWeekStartDate(from date: Date = Date()) -> Date {
    return Calendar.current.date(byAdding: .day, value: -6, to: date)!
}

func createLastWeekPredicate(from endDate: Date = Date()) -> NSPredicate {
    let startDate = getLastWeekStartDate(from: endDate)
    return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
}

/// This is commonly used for date intervals so that we get the last seven days worth of data,
/// because we assume today (`Date()`) is providing data as well.
func getStartDate(from date: Date = Date(), variant type: DateRangeVariant = .DAILY(7)) -> Date {
    switch type {
    case .DAILY(let value):
        return Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: value > 0 ? -(value - 1) : -6, to: date)!)
    case .WEEKLY(let value):
        let weekDay = Calendar.current.component(.weekday, from: date)
        let weekStartDate = Calendar.current.startOfDay(for:Calendar.current.date(byAdding: .day, value: -(weekDay - 1), to: date)!)
        return Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .weekOfYear, value: value > 1 ? -(value - 1) : -5, to: weekStartDate)!)
    case .MONTHLY(let value):
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        let firstOfMonth = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1))
        let monthStartDate = Calendar.current.startOfDay(for:firstOfMonth!)
        return Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .month, value: value > 0 ? -(value - 1) : -11, to: monthStartDate)!)
    case .YEARLY(let value):
        let year = Calendar.current.component(.year, from: date)
        let firstOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))
        let yearStartDate = Calendar.current.startOfDay(for:firstOfYear!)
        return Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .year, value: value > 0 ? -(value - 1) : -4, to: yearStartDate)!)
    }
}

typealias PredicateDate = (predicate: NSPredicate, date: DateComponents)

func createPredicate(from endDate: Date = Date(), variant type: DateRangeVariant = .DAILY(7)) -> PredicateDate {
    let startDate = getStartDate(from: endDate, variant: type)
    switch type {
    case .DAILY:
        return (HKQuery.predicateForSamples(withStart: startDate, end: endDate), DateComponents(day: 1))
    case .WEEKLY:
        return (HKQuery.predicateForSamples(withStart: startDate, end: endDate), DateComponents(day: 7))
    case .MONTHLY:
        return (HKQuery.predicateForSamples(withStart: startDate, end: endDate), DateComponents(month: 1))
    case .YEARLY:
        return (HKQuery.predicateForSamples(withStart: startDate, end: endDate), DateComponents(year: 1))
    }
    
}

/// Return the most preferred `HKStatisticsOptions` for a data type identifier. Defaults to `.discreteAverage`.
func getStatisticsOptions(for dataTypeIdentifier: String) -> HKStatisticsOptions {
    var options: HKStatisticsOptions = .discreteAverage
    let sampleType = getSampleType(for: dataTypeIdentifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier)
        
        switch quantityTypeIdentifier {
        case .stepCount, .distanceWalkingRunning:
            options = .cumulativeSum
        case .sixMinuteWalkTestDistance, .walkingSpeed:
            options = .discreteAverage
        default:
            break
        }
    }
    
    return options
}

/// Return the statistics value in `statistics` based on the desired `statisticsOption`.
func getStatisticsQuantity(for statistics: HKStatistics, with statisticsOptions: HKStatisticsOptions) -> HKQuantity? {
    var statisticsQuantity: HKQuantity?
    
    switch statisticsOptions {
    case .cumulativeSum:
        statisticsQuantity = statistics.sumQuantity()
    case .discreteAverage:
        statisticsQuantity = statistics.averageQuantity()
    default:
        break
    }
    
    return statisticsQuantity
}
