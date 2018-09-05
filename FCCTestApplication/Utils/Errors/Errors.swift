//
//  Errors.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 05/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

enum PointsApiError: Error {
    case unknownServiceError
    case knownServiceError(String)
    case unableToParseJSON
    case unableToDecodeErrorMessage
    case invalidRequestArguments
}
