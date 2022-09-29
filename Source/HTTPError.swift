//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Alamofire

public enum HTTPError: Error {
    public enum ResponseError: Error, LocalizedError {
        case JSONError(String)
        case serverError(String)
        case decodeError(String)
        
        public var errorDescription: String? {
            switch self {
            case .JSONError(let string), .serverError(let string), .decodeError(let string):
                return string
            }
        }
    }

//    case invalidDataRequest(dataRequest: DataRequest)
}

extension Error {
    public var asHTTPError: HTTPError? {
        self as? HTTPError
    }
    
    public var asResponseError: HTTPError.ResponseError? {
        self as? HTTPError.ResponseError
    }
    
    public var errorMessage: String? {
        if let afError = asAFError {
            if let realError = afError.realError {
                if let asResponseError = realError.asResponseError {
                    return asResponseError.errorDescription
                }
            }
            return afError.errorDescription
        }
        return localizedDescription
    }
}

extension LocalizedError {
    public var errorMessage: String? {
        if let afError = asAFError {
            if let realError = afError.realError {
                if let asResponseError = realError.asResponseError {
                    return asResponseError.errorDescription
                }
            }
        }
        return errorDescription
    }
}

extension AFError: CustomNSError {}

extension AFError {
    // error.asAFError(or: .responseSerializationFailed(reason: .customSerializationFailed(error: error)))
    public var realError: Error? {
        if case let .responseSerializationFailed(reason: reason) = self {
            if case let .customSerializationFailed(error: error) = reason {
                return error
            }
        }
        return nil
    }
}
