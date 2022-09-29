//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Alamofire

extension URLEncoding {
	public func queryParameters(_ parameters: Parameters) -> [(String, String)] {
		var components: [(String, String)] = []
		for key in parameters.keys.sorted(by: <) {
			let value = parameters[key]!
			components += queryComponents(fromKey: key, value: value)
		}
		return components
	}
}
