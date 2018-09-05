//
//  TestCase.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 05/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

import Foundation

enum TestCase {
    case none
    case fewPoints
    case manyPoints
    case genericFailure
    case wrongAttributes
    
    var mockJSONFilePath: String? {
        return Bundle.main.path(forResource: String(describing: self), ofType: "json")
    }
    
    var tableTitle: String {
        switch self {
        case .none:
            return "Only use when certificates are fixed"
        case .fewPoints, .genericFailure, .manyPoints, .wrongAttributes:
            return String(describing: self)
        }
    }
    
    static var allCases: [TestCase] {
        return [.none, .fewPoints, .manyPoints, .wrongAttributes, .genericFailure]
    }
}
