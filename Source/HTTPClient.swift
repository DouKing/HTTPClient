//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Alamofire

public typealias Result = Swift.Result

public protocol HTTPClient {
    var baseURL: URL { get }
    var defaultHttpHeaders: HTTPHeaders { get }
    var defaultParameters: Parameters { get }
    var parameterEncoding: ParameterEncoding { get }

    var validate: ((_ data: Any) -> Result<Any, HTTPError.ResponseError>)? { get }
    var decodePath: String? { get }

	func didCreateRequest<T: HTTPRequest>(_ dataRequest: DataRequest, with http: T)

	@discardableResult
	func send<T: HTTPRequest>(_ http: T) -> DataRequest

	@discardableResult
	func upload<T: HTTPRequest>(_ http: T) -> UploadRequest
}

//--------------------------------------------------------------------------------
// MARK: -
//--------------------------------------------------------------------------------

extension HTTPClient {
	func didCreateRequest<T: HTTPRequest>(_ dataRequest: DataRequest, with http: T) {}

	@discardableResult
	public func send<T: HTTPRequest>(_ http: T) -> DataRequest {
		var headers: HTTPHeaders = self.defaultHttpHeaders
		var parameters: Parameters = self.defaultParameters

		http.headers?.dictionary.forEach({ (key: String, value: String) in
			headers.add(name: key, value: value)
		})

		http.parameters?.forEach({ (key: String, value: Any) in
			parameters[key] = value
		})

		let baseURL = http.baseURL ?? self.baseURL
		let url = { () -> URL in
			if http.path.isEmpty { return baseURL }
			return baseURL.appendingPathComponent(http.path)
		}()
        #if DEBUG
        #else
            .httpsURL
        #endif

		let parameterEncoding = http.parameterEncoding ?? self.parameterEncoding

		let dataRequest = AF.request(
			url,
			method: http.method,
			parameters: parameters,
			encoding: parameterEncoding,
			headers: headers
		)

		let decodePath = http.decodePath ?? self.decodePath
		let validate = http.validate ?? self.validate

		dataRequest.designatedPath = decodePath
		dataRequest.validate = validate
		dataRequest.dataPreprocessor = http.dataPreprocessor

		didCreateRequest(dataRequest, with: http)
		return dataRequest
	}

	@discardableResult
	public func upload<T: HTTPRequest>(_ http: T) -> UploadRequest {
		var headers: HTTPHeaders = self.defaultHttpHeaders
		var parameters: Parameters = self.defaultParameters
		let multipartFormData = http.multipartFormData

		http.headers?.dictionary.forEach({ (key: String, value: String) in
			headers.add(name: key, value: value)
		})

		http.parameters?.forEach({ (key: String, value: Any) in
			parameters[key] = value
		})

		let baseURL = http.baseURL ?? self.baseURL
		let url = { () -> URL in
			if http.path.isEmpty { return baseURL }
			return baseURL.appendingPathComponent(http.path)
		}()
        #if DEBUG
        #else
            .httpsURL
        #endif

		let block = { (multipart: MultipartFormData) in
			URLEncoding.default.queryParameters(parameters).forEach { (key, value) in
				if let data = value.data(using: .utf8) {
					multipart.append(data, withName: key)
				}
			}
			multipartFormData?(multipart)
		}
		let uploadRequest = AF.upload(multipartFormData: block, to: url, method: http.method, headers: headers)

		let decodePath = http.decodePath ?? self.decodePath
		let validate = http.validate ?? self.validate

		uploadRequest.designatedPath = decodePath
		uploadRequest.validate = validate
		uploadRequest.dataPreprocessor = http.dataPreprocessor

		didCreateRequest(uploadRequest, with: http)
		return uploadRequest
	}
}
