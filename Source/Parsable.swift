//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

public protocol Parsable {
    static func parse(from json: Any) throws -> Self?
}

public struct UnDecode: Parsable {}

extension Parsable {
    public static func parse(from json: Any) throws -> Self? {
        return nil
    }
}

extension Parsable where Self: Decodable {
    public static func parse(from json: Any) throws -> Self? {
        if Self.self is UnDecode.Type { return nil }
        guard JSONSerialization.isValidJSONObject(json),
            let data = try? JSONSerialization.data(withJSONObject: json)
            else { return nil }

        let model = try JSONDecoder().decode(Self.self, from: data)
        return model
    }
}

extension Array: Parsable where Element: Parsable {
	public static func parse(from json: Any) throws -> Self? {
		guard let arr = json as? [Any] else { return nil }
		var models: [Element] = []
		for obj in arr {
			if let model = try Element.parse(from: obj) {
				models.append(model)
			}
		}
		return models
	}
}
