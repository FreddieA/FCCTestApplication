//
//  Constants.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 05/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

import Foundation

struct Constants {
    static let pointsApiUrl = "https://demo.bankplus.ru/mobws/json/pointsList"
}

extension Notification.Name {
    static let pointsUpdated = Notification.Name("pointsUpdated")
    static let errorOccurred = Notification.Name("errorOccurred")
}
