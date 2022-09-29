//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Alamofire

public final class ParsableResponseSerializer<T: Parsable>: ResponseSerializer {
    public let dataPreprocessor: DataPreprocessor
	public let designatedPath: String?
	public let validate: ((_ data: Any) -> Swift.Result<Any, HTTPError.ResponseError>)?
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>

    /// Creates an instance using the values provided.
    ///
    /// - Parameters:
    ///   - dataPreprocessor:    `DataPreprocessor` used to prepare the received `Data` for serialization.
	///   - designatedPath:		 The decode path, `data.user.name`.
    ///   - emptyResponseCodes:  The HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
    ///   - emptyRequestMethods: The HTTP request methods for which empty responses are allowed. `[.head]` by default.
	public init(
		dataPreprocessor: DataPreprocessor = ParsableResponseSerializer.defaultDataPreprocessor,
		designatedPath: String? = nil,
		validate: ((_ data: Any) -> Swift.Result<Any, HTTPError.ResponseError>)? = nil,
		emptyResponseCodes: Set<Int> = ParsableResponseSerializer.defaultEmptyResponseCodes,
		emptyRequestMethods: Set<HTTPMethod> = ParsableResponseSerializer.defaultEmptyRequestMethods
	) {
        self.dataPreprocessor = dataPreprocessor
		self.designatedPath = designatedPath
		self.validate = validate
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
    }

    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        guard error == nil else { throw error! }

        guard var data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }

            guard let emptyResponseType = T.self as? EmptyResponse.Type, let emptyValue = emptyResponseType.emptyValue() as? T else {
                throw AFError.responseSerializationFailed(reason: .invalidEmptyResponse(type: "\(T.self)"))
            }

            return emptyValue
        }

        data = try dataPreprocessor.preprocess(data)
		var json = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))

		if let validate = validate {
			let result = validate(json)
			switch result {
				case .failure(let error):
					throw error
				case .success(let dic):
					json = dic
			}
		}

		if let paths = designatedPath?.components(separatedBy: ".").filter({ !$0.isEmpty }), paths.count > 0 {
			json = (json as? NSDictionary)?.value(forKeyPath: designatedPath!) ?? [:]
		}

		do {
			guard let model = try T.parse(from: json) else {
				throw HTTPError.ResponseError.decodeError("解析失败")
			}
			return model
		} catch {
			throw error
		}
    }
}

extension DataRequest {
    /// Adds a handler to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - type:              `Parsable` type to parse from response data.
    ///   - queue:             The queue on which the completion handler is dispatched. `.main` by default.
    ///   - completionHandler: A closure to be executed once the request has finished.
    ///
    /// - Returns:             The request.
    @discardableResult
    public func responseParsable<T: Parsable>(
        of type: T.Type = T.self,
        queue: DispatchQueue = .main,
        completionHandler: @escaping (AFDataResponse<T>) -> Void
    ) -> Self {
		let serializer = ParsableResponseSerializer<T>(
			dataPreprocessor: dataPreprocessor ?? ParsableResponseSerializer<T>.defaultDataPreprocessor,
			designatedPath: designatedPath,
			validate: validate
		)
        return response(queue: queue, responseSerializer: serializer, completionHandler: completionHandler)
    }
}

#if !((os(iOS) && (arch(i386) || arch(arm))) || os(Windows) || os(Linux))

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension DataRequest {
    /// Creates a `DataResponsePublisher` for this instance and uses a `ParsableResponseSerializer` to serialize the
    /// response.
    ///
    /// - Parameters:
    ///   - type:                `Parsable` type to which to decode response `Data`. Inferred from the context by
    ///                          default.
    ///   - queue:               `DispatchQueue` on which the `DataResponse` will be published. `.main` by default.
    ///
    /// - Returns:               The `DataResponsePublisher`.
    public func publishParsable<T: Parsable>(
        of type: T.Type = T.self,
        queue: DispatchQueue = .main
    ) -> DataResponsePublisher<T> {
        let serializer = ParsableResponseSerializer<T>(
            dataPreprocessor: dataPreprocessor ?? ParsableResponseSerializer<T>.defaultDataPreprocessor,
            designatedPath: designatedPath,
            validate: validate
        )
        return publishResponse(using: serializer, on: queue)
    }
}

#endif

#if compiler(>=5.6.0) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension DataRequest {
    /// Creates a `DataTask` to `await` serialization of a `Parsable` value.
    ///
    /// - Parameters:
    ///   - type:                      `Parsable` type to decode from response data.
    ///   - shouldAutomaticallyCancel: `Bool` determining whether or not the request should be cancelled when the
    ///                                enclosing async context is cancelled. Only applies to `DataTask`'s async
    ///                                properties. `false` by default.
    ///
    /// - Returns: The `DataTask`.
    public func serializingParsable<T: Parsable>(
        of type: T.Type = T.self,
        automaticallyCancelling shouldAutomaticallyCancel: Bool = false
    ) -> DataTask<T> {
        let serializer = ParsableResponseSerializer<T>(
            dataPreprocessor: dataPreprocessor ?? ParsableResponseSerializer<T>.defaultDataPreprocessor,
            designatedPath: designatedPath,
            validate: validate
        )
        return serializingResponse(
            using: serializer,
            automaticallyCancelling: shouldAutomaticallyCancel)
    }
}

#endif
