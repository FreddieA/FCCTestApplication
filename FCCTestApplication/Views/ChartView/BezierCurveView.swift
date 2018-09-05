//
//  BezierCurveView.swift
//
//  Created by Mikhail Kirillov on 27/12/2017.
//  Copyright © 2017 Sibext Ltd. All rights reserved.
//

import UIKit
import Foundation

struct DataPoint {
    let value: Float
    let timeUnit: Int
}

private let dotsColor: UIColor = .green
private let dotsRadius: CGFloat = 8
private let lineWidth: CGFloat = 2
private let lineColor: UIColor = .black

class BezierCurveView: UIView {

    private var rawData = [CGPoint]()

    private var pointLayers = [CAShapeLayer]()
    private var lineLayer = CAShapeLayer()

    private var pointSize = CGSize(width: dotsRadius, height: dotsRadius)

    private var valuePoints: [CGPoint] {
        let xPoints = rawData.map { $0.x }
        let yPoints = rawData.map { $0.y }

        var resultingPoints = [CGPoint]()
        if let maxX = xPoints.max(), let maxY = yPoints.max(), maxX > 0, maxY > 0 {
            for point in rawData {
                let resultingX = (frame.width * point.x / maxX) - pointSize.width / 2
                var resultingY: CGFloat = 0
                if point.y == 0 {
                    resultingY = frame.height
                } else {
                    resultingY = (maxY > 1) ? frame.height * (point.y / maxY)
                        : frame.height - frame.height * (point.y / maxY)
                }
                resultingPoints.append(CGPoint(x: resultingX, y: resultingY - pointSize.height / 2))
            }
            return resultingPoints
        }
        return []
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        pointLayers.removeAll()

        drawLines()
        drawPoints()
    }

    func displayPoints(points: [CGPoint]) {
        self.isHidden = points.isEmpty
        
        rawData = points
        setNeedsLayout()
        layoutIfNeeded()
    }

    func displayPoints(legend: [String: CGPoint]) {
        displayPoints(points: legend.map { $0.value })
    }

    private func drawPoints() {
        for point in valuePoints {
            let circleLayer = CAShapeLayer()
            circleLayer.bounds = CGRect(x: 0, y: 0, width: pointSize.width, height: pointSize.height)
            circleLayer.path = UIBezierPath(ovalIn: circleLayer.bounds).cgPath
            circleLayer.fillColor = dotsColor.cgColor
            circleLayer.position = point
            layer.addSublayer(circleLayer)
        }
    }

    private func move(point: CGPoint) -> CGPoint  {
        var newPoint = CGPoint.zero
        newPoint.x = min(point.x, frame.width)
        newPoint.x = max(newPoint.x, frame.origin.x)

        newPoint.y = min(point.y, frame.height)
        newPoint.y = max(newPoint.y, frame.origin.y)
        return newPoint
    }

    private func drawLines() {
        if valuePoints.isEmpty {
            return
        }
        let linePath = UIBezierPath()

        valuePoints.forEach { point in
            if point == valuePoints.first {
                linePath.move(to: point)
            } else {
                linePath.addLine(to: point)
            }
        }

        lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.lineJoin = kCALineJoinRound

        layer.addSublayer(lineLayer)
    }
}
