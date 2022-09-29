//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation
import Alamofire

extension DataRequest {
	private struct AssociatedKeys {
		static var DesignatedPath = "lvm_DesignatedPath"
		static var Validate = "lvm_validate"
		static var DataPreprocessor = "lvm_dataPreprocessor"
	}

	var designatedPath: String? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.DesignatedPath) as? String
		}
		set {
			objc_setAssociatedObject(
				self,
				&AssociatedKeys.DesignatedPath,
				newValue,
				objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
			)
		}
	}

	var validate: ((_ data: Any) -> Result<Any, HTTPError.ResponseError>)? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.Validate)
				as? ((_ data: Any) -> Result<Any, HTTPError.ResponseError>)
		}

		set {
			objc_setAssociatedObject(
				self,
				&AssociatedKeys.Validate,
				newValue,
				.OBJC_ASSOCIATION_COPY_NONATOMIC
			)
		}
	}

	var dataPreprocessor: DataPreprocessor? {
		get {
			if let obj = objc_getAssociatedObject(self, &AssociatedKeys.DataPreprocessor) {
				let processor = (obj as AnyObject) as? DataPreprocessor
				return processor
			}
			return nil
		}

		set {
			objc_setAssociatedObject(
				self,
				&AssociatedKeys.DataPreprocessor,
				newValue,
				.OBJC_ASSOCIATION_RETAIN_NONATOMIC
			)
		}
	}
}

extension DataRequest {
    @discardableResult
    public func debug() -> DataRequest {
#if DEBUG
        AF.rootQueue.asyncAfter(deadline: .now() + 1) {
            print(self.cURLDescription())
        }
#endif
        return self
    }
}
