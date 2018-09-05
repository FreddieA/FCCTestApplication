//
//  ChartView.swift
//
//  Created by Mikhail Kirillov on 27/12/2017.
//  Copyright © 2017 Sibext Ltd. All rights reserved.
//

import UIKit

class ChartView: UIView {

    private let gridView = GridView(frame: .zero)
    private var graphView = BezierCurveView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        graphView = BezierCurveView(frame: gridView.usableSpace)
    }
    
    required init?(coder aDecoder: NSCoder) {
        graphView = BezierCurveView(frame: gridView.usableSpace)
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if gridView.superview == nil {
            addSubview(gridView)
        }
        if graphView.superview == nil {
            gridView.addSubview(graphView)
        }
        gridView.frame = bounds
        graphView.frame = gridView.usableSpace

        gridView.setNeedsDisplay()
        graphView.setNeedsDisplay()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.displayPoints(points: [])
    }

    func displayPoints(points: [CGPoint]) {
        graphView.frame = gridView.usableSpace
        gridView.displayPoints(points: points)
        graphView.displayPoints(points: points)

        layoutSubviews()
    }
}
