//
//  DataPointsService.swift
//  FCCTestApplication
//
//  Created by Mikhail Kirillov on 05/09/2018.
//  Copyright © 2018 Mikhail Kirillov. All rights reserved.
//

import Foundation

class DataPointsService {
    
    private let testCase: TestCase
    private let requestUrlPath: String
    private(set) var points = [Point]() {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: .pointsUpdated))
            }
        }
    }
    
    init(requestUrl: String = Constants.pointsApiUrl, _ testCase: TestCase = .genericFailure) {
        requestUrlPath = requestUrl
        self.testCase = testCase
    }
    
    func requestPoints(_ numberOfPoints: Int) {
        guard case TestCase.none = testCase else {
            handleTestCase(testCase)
            return
        }
        
        guard let url = URL(string: requestUrlPath) else {
            handleError(nil)
            return
        }
        
        var request: URLRequest = .init(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["version": 1.1, "count": numberOfPoints], options: [])
        } catch {
            handleError(error)
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let strongSelf = self else {
                return
            }
            guard let data = data else {
                strongSelf.handleError(error)
                return
            }
            do {
                let response = try DataPointsResponse.init(data)
                strongSelf.points = response.cluster.points
            } catch {
                strongSelf.handleError(error)
            }
        })
        task.resume()
    }
    
    func addListener(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: .pointsUpdated, object: nil)
        NotificationCenter.default.addObserver(observer, selector: selector, name: .errorOccurred, object: nil)
    }
    
    private func handleTestCase(_ test: TestCase) {
        guard let mockFilePath = test.mockJSONFilePath else {
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: mockFilePath), options: .mappedIfSafe)
            let response = try DataPointsResponse(data)
            points = response.cluster.points
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error?) {
        guard let error = error else {
            return
        }
        DispatchQueue.main.async {
            let notification = Notification(name: .errorOccurred, object: nil, userInfo: ["error": error])
            NotificationCenter.default.post(notification)
        }
    }
}
