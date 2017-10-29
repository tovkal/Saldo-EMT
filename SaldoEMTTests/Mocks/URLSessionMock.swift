//
//  URLSessionMock.swift
//  SaldoEMTTests
//
//  Created by Andrés Pizá Bückmann on 29/10/2017.
//  Copyright © 2017 tovkal. All rights reserved.
//

import Foundation
@testable import SaldoEMT

class URLSessionMock: URLSessionProtocol {
    private (set) var dataTaskWithRequestCalled = false
    private (set) var request: URLRequest?

    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    var dataTask = URLSessionDataTaskMock()

    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        dataTaskWithRequestCalled = true
        self.request = request
        completionHandler(data, urlResponse, error)
        return dataTask
    }
}

class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false

    func resume() {
        resumeWasCalled = true
    }
}
