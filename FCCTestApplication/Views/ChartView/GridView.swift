//
//  GraphGridView.swift
//
//  Created by Mikhail Kirillov on 27/12/2017.
//  Copyright © 2017 Sibext Ltd. All rights reserved.
//

import UIKit

private let leftOffset: CGFloat = 50
private let bottomOffset: CGFloat = 30

private let axisWidth: NSInteger = 3
private let dashWidth: NSNumber = 0.5

private let numberOfHorizontalDashedLines: CGFloat = 3
private let numberOfVerticalDashedLines: CGFloat = 24 - 1 // hrs

class GridView: UIView {

    private var valuePoints: [CGPoint] = []
    private var legendStrings: [String] = []

    private var axisThickness: CGFloat {
        return CGFloat(axisWidth) / UIScreen.main.scale
    }

    private var dashThickness: CGFloat {
        return CGFloat(truncating: dashWidth) * UIScreen.main.scale
    }

    private var horizontalValues: [CGFloat] {
        return valuePoints.map { $0.x }
    }

    private var verticalValues: [CGFloat] {
        let yPoints = valuePoints.map { $0.y }
        guard let maxY = yPoints.max() else {
            return []
        }
        let diff = maxY / numberOfHorizontalDashedLines
        var values = [CGFloat]()
        for index in 0...Int(numberOfHorizontalDashedLines) {
            values.append(diff * CGFloat(index))
        }
        return values
    }

    private var horizontalLabelSize: CGSize {
        if horizontalValues.isEmpty {
            return .zero
        }
        return CGSize(width: (frame.width - leftOffset) / CGFloat(horizontalValues.count), height: bottomOffset)
    }

    private var verticalLabelSize: CGSize {
        if verticalValues.isEmpty {
            return .zero
        }
        return CGSize(width: leftOffset, height: (frame.height - bottomOffset) / CGFloat(verticalValues.count))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func displayPoints(points: [CGPoint]) {
        self.isHidden = points.isEmpty
        valuePoints = points
        setNeedsDisplay()
    }

    var usableSpace: CGRect {
        return CGRect(x: axisThickness + verticalLabelSize.width,
                      y: dashThickness,
                      width: bounds.width - axisThickness - dashThickness * 2 - verticalLabelSize.width,
                      height: bounds.height - axisThickness - dashThickness * 2 - horizontalLabelSize.height)
    }

    private func drawText(text: NSString, frame: CGRect, mode: UIViewContentMode) {
        let paragraphStyle = NSMutableParagraphStyle()

        var centerVertically: Bool
        if mode == .center {
            paragraphStyle.alignment = .center
            centerVertically = true
        } else {
            paragraphStyle.alignment = .right
            centerVertically = false
        }
        text.draw(in: frame, withAttributes: [.font: UIFont.systemFont(ofSize: 12),
                                              .paragraphStyle: paragraphStyle,
                                              .foregroundColor: UIColor.gray], verticallyCentered: centerVertically)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(axisThickness)
        context.setLineJoin(CGLineJoin.bevel)

        let xAxisPath = CGMutablePath()
        xAxisPath.move(to: CGPoint(x: verticalLabelSize.width, y: rect.height - axisThickness / 2 - horizontalLabelSize.height))
        xAxisPath.addLine(to: CGPoint(x: rect.width, y: rect.height - axisThickness / 2 - horizontalLabelSize.height))
        context.addPath(xAxisPath)

        let yAxisPath = CGMutablePath()
        yAxisPath.move(to: CGPoint(x: axisThickness / 2 + verticalLabelSize.width, y: 0))
        yAxisPath.addLine(to: CGPoint(x: axisThickness / 2 + verticalLabelSize.width,
                                      y: rect.height - horizontalLabelSize.height))
        context.addPath(yAxisPath)
        context.strokePath()

        context.setLineDash(phase: 2, lengths: [2])
        context.setLineWidth(dashThickness)

        let verticalSegmentWidth = (rect.height - axisThickness - horizontalLabelSize.height) / numberOfHorizontalDashedLines
        for index in 0...Int(numberOfHorizontalDashedLines) {
            let number = CGFloat(index)
            let leftPoint = CGPoint(x: verticalLabelSize.width, y: verticalSegmentWidth * number)
            let rightPoint = CGPoint(x: rect.width, y: CGFloat(verticalSegmentWidth * number))

            let horizontalDashLinePath = CGMutablePath()
            horizontalDashLinePath.move(to: leftPoint)
            horizontalDashLinePath.addLine(to: rightPoint)
            context.addPath(horizontalDashLinePath)

            let diff = (number / numberOfHorizontalDashedLines) * (frame.height - horizontalLabelSize.height - axisThickness)
            let rect = CGRect(x: 0,
                              y: frame.height - diff - horizontalLabelSize.height - axisThickness,
                              width: verticalLabelSize.width - axisThickness,
                              height: verticalLabelSize.height)

            if !verticalValues.isEmpty, let maxX = verticalValues.max(), maxX >= 0 {
                let value = (CGFloat(index) / numberOfHorizontalDashedLines) * maxX
                let format: NSString = value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.3f"
                drawText(text: NSString(format: format, value), frame: rect, mode: .left)
            }
        }

        for index in 1...Int(numberOfVerticalDashedLines) {
            let number = CGFloat(index)
            let dashLinePath = CGMutablePath()
            let upperPoint = CGPoint(x: horizontalLabelWidth * number + axisThickness + verticalLabelSize.width, y: 0)
            let lowerPoint = CGPoint(x: horizontalLabelWidth * number + axisThickness + verticalLabelSize.width,
                                     y: rect.height - horizontalLabelSize.height)
            dashLinePath.move(to: upperPoint)
            dashLinePath.addLine(to: lowerPoint)
            context.addPath(dashLinePath)
        }

        for value in horizontalValues {
            if value.truncatingRemainder(dividingBy: 3) == 0 {
                let lowerPoint = CGPoint(x: horizontalLabelWidth * value + axisThickness + verticalLabelSize.width,
                                         y: rect.height - horizontalLabelSize.height)
                if lowerPoint.x - horizontalLabelWidth / 3 < frame.width - horizontalLabelWidth {
                    drawText(text: NSString(format: "%.0f", value),
                             frame: CGRect(x: lowerPoint.x - horizontalLabelWidth / 3,
                                           y: lowerPoint.y,
                                           width: horizontalLabelWidth * 2,
                                           height: horizontalLabelSize.height),
                             mode: .center)
                }
            }
        }

        drawLegendText(rect: frame, context: context)
        context.strokePath()
    }

    private var horizontalLabelWidth: CGFloat {
        return (bounds.width - axisThickness - verticalLabelSize.width) / CGFloat(horizontalValues.count)
    }

    private func drawLegendText(rect: CGRect, context: CGContext) {
        for index in 0..<legendStrings.count {
            let lowerPoint = CGPoint(x: horizontalLabelWidth * CGFloat(index) + axisThickness + verticalLabelSize.width,
                                     y: rect.height - horizontalLabelSize.height)
            if lowerPoint.x - horizontalLabelWidth / 2 < frame.width - horizontalLabelWidth {
                drawText(text: legendStrings[index] as NSString,
                         frame: CGRect(x: lowerPoint.x - horizontalLabelWidth / 2,
                                       y: lowerPoint.y,
                                       width: horizontalLabelWidth,
                                       height: horizontalLabelSize.height),
                         mode: .center)
            }
        }
    }

}

private extension NSString {

    func draw(in rect: CGRect, withAttributes attributes: [NSAttributedStringKey: Any], verticallyCentered: Bool) {
        let attrSize = size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.origin.x,
                                  y: rect.origin.y + (verticallyCentered ? (rect.size.height - attrSize.height) / 2.0 : 0),
                                  width: rect.size.width,
                                  height: attrSize.height)
        draw(in: centeredRect, withAttributes: attributes)
    }

}
