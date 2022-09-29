//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias Parameters = Alamofire.Parameters
public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias MultipartFormData = Alamofire.MultipartFormData

public protocol HTTPRequest {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var parameterEncoding: ParameterEncoding? { get }
    var headers: HTTPHeaders? { get }
	var multipartFormData: ((MultipartFormData) -> Void)? { get }
    var validate: ((_ data: Any) -> Result<Any, HTTPError.ResponseError>)? { get }
	var dataPreprocessor: DataPreprocessor? { get }

    associatedtype DecodableType: Parsable
    var decodePath: String? { get }
}

public extension HTTPRequest {
    var baseURL: URL? { return nil }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? { return nil }
    var parameterEncoding: ParameterEncoding? { return nil }
    var headers: HTTPHeaders? { return nil }
    var decodePath: String? { return nil }
	var multipartFormData: ((MultipartFormData) -> Void)? { return nil }
    var validate: ((_ data: Any) -> Result<Any, HTTPError.ResponseError>)? { return nil }
	//var dataPreprocessor: DataPreprocessor? { return nil }
}
