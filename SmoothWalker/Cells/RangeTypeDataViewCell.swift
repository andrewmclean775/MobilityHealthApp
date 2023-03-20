/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection view cell that displays a chart.
*/

import UIKit
import CareKitUI

class RangeTypeDataViewCell: UICollectionViewCell {
        
    var dataTypeIdentifier: String!
    var statisticalValues: [TrackingData] = []
    
    var variant: DateRangeVariant!
    
    var chartView: OCKCartesianChartView = {
        let chartView = OCKCartesianChartView(type: .bar)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        return chartView
    }()
    
    init(dataTypeIdentifier: String) {
        self.dataTypeIdentifier = dataTypeIdentifier
        
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        contentView.addSubview(chartView)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        constraints += createChartViewConstraints()
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func createChartViewConstraints() -> [NSLayoutConstraint] {
        let leading = chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let top = chartView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let trailing = chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let bottom = chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
        trailing.priority -= 1
        bottom.priority -= 1

        return [leading, top, trailing, bottom]
    }
    
    func updateChartView(with dataTypeIdentifier: String, values: [TrackingData], title: String = createChartDateRangeLabel(), variant: DateRangeVariant) {
        self.dataTypeIdentifier = dataTypeIdentifier
        self.statisticalValues = values
        self.variant = variant
        
        // Update headerView
        chartView.headerView.titleLabel.text = getDataTypeName(for: dataTypeIdentifier) ?? "Data"
        chartView.headerView.detailLabel.text = title
        
        // Update graphView
        chartView.applyDefaultConfiguration()
        chartView.graphView.horizontalAxisMarkers = createHorizontalAxisMarkers(values: values, variant: variant)
        
        // Update graphView dataSeries
        let dataPoints: [CGFloat] = statisticalValues.map { CGFloat($0.value) }
        
        guard
            let unit = preferredUnit(for: dataTypeIdentifier),
            let unitTitle = getUnitDescription(for: unit)
        else {
            return
        }
        
        chartView.graphView.dataSeries = [
            OCKDataSeries(values: dataPoints, title: unitTitle)
        ]
    }
}
