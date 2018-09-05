//
//  Points.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 05/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

import Foundation
import CoreGraphics

struct Point {
    let xAxis: Double
    let yAxis: Double
    
    init(_ dictionary: [String : Any]) throws {
        guard let xField = dictionary["x"] as? Double, let yField = dictionary["y"] as? Double else {
            throw PointsApiError.unableToParseJSON
            }
        xAxis = xField
        yAxis = yField
    }
    
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(xAxis), y: CGFloat(yAxis))
    }
}

struct PointCluster {
    
    private(set) var points: [Point]
    
    init() {
        points = [Point]()
    }
    
    init(_ dictionary: [String : Any]) throws {
        guard let pointsDict = dictionary["points"] as? [Dictionary<String, Any>] else {
            throw PointsApiError.unableToParseJSON
        }
        points = [Point]()
        for point in pointsDict {
            points.append(try Point(point))
        }
        points.sort { $0.xAxis > $1.xAxis}
    }
}
