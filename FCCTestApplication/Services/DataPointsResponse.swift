//
//  DataPointsResponse.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 05/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

import Foundation

class DataPointsResponse {
    
    var cluster = PointCluster()
    
    init(_ data: Data, _ encoding: String.Encoding = .utf8) throws {
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDict = jsonResult as? [String: Any] else {
            throw PointsApiError.unableToParseJSON
        }
        guard let result = jsonDict["result"] as? Int else {
            throw PointsApiError.unableToParseJSON
        }
        
        switch result {
        case 0:
            try processResult(jsonDict)
        case -100:
            throw PointsApiError.invalidRequestArguments
        case -1:
            if let response = jsonDict["response"] as? [String: String], let messageEncoded = response["message"] {
                guard let decodedData = Data(base64Encoded: messageEncoded),
                    let decodedString = String(data: decodedData, encoding: .utf8) else {
                        throw PointsApiError.unableToDecodeErrorMessage
                }
                throw PointsApiError.knownServiceError(decodedString)
            }
        default:
            break
        }
    }
    
    private func processResult(_ dict: [String: Any]) throws {
        guard let response = dict["response"] as? [String: Any] else {
            throw PointsApiError.unableToParseJSON
        }
        cluster = try .init(response)
    }
}
