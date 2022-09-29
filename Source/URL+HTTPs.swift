//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

extension URL {
	var httpsURL: URL {
		guard let scheme = scheme, scheme == "http" else { return self }
		let str = absoluteString.replacingOccurrences(of: "http://", with: "https://")
		guard let url = URL(string: str) else { return self }
		return url
	}
}
