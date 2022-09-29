//===----------------------------------------------------------*- swift -*-===//
//
// Created by wuyikai on 2022/8/18.
// Copyright © 2022 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Alamofire

public enum NetworkType: Int {
    public typealias RawValue = Int

    case unknown            = -1
    case notReachable       = 0
    case viaWiFi            = 1
    case viaWWAN            = 2
    case via2G              = 3
    case via3G              = 4
    case via4G              = 5

    static var current: NetworkType {
        guard let status = NetworkReachabilityManager()?.status else {
            return .unknown
        }
        switch status {
        case .notReachable: return .notReachable
        case .unknown: return .unknown
        case .reachable(let type):
            switch type {
            case .ethernetOrWiFi: return .viaWiFi
            case .cellular:
#if (os(iOS))
				let block = { () -> String? in
					if #available(iOS 12.0, *) {
						return CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.values.first
					} else {
						return CTTelephonyNetworkInfo().currentRadioAccessTechnology
					}
				}
                guard let technology = block(), let cellular = self.map[technology] else {
                    return .viaWWAN
                }
                return cellular
#else
                return .viaWWAN
#endif
            }
        }
    }
}

extension NetworkType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .notReachable:
            return "Unknown"
        case .viaWiFi:
            return "Wifi"
        case .viaWWAN:
            return "WWAN"
        case .via2G:
            return "2G"
        case .via3G:
            return "3G"
        case .via4G:
            return "4G"
        }
    }
}

#if (os(iOS))

import CoreTelephony

extension NetworkType {
    static var carrier: String {
        let block = { () -> CTCarrier? in
            if #available(iOS 12.0, *) {
                return CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values.first
            } else {
                return CTTelephonyNetworkInfo().subscriberCellularProvider
            }
        }

        guard let carrier = block(), carrier.isoCountryCode != nil else {
            return "n/?"
        }
        var country = carrier.mobileCountryCode ?? "n"
        var mobile = carrier.mobileNetworkCode ?? "?"
        if country == "460" {
            country = "中国"
            switch mobile {
            case "00", "02", "07", "08": mobile = "移动"
            case "01", "06", "09": mobile = "联通"
            case "03", "05", "11": mobile = "电信"
            default: break
            }
        }
        return "\(country)/\(mobile)"
    }

    private static let map: [String: NetworkType] = [
        CTRadioAccessTechnologyGPRS: .via2G,
        CTRadioAccessTechnologyEdge: .via2G,
        CTRadioAccessTechnologyWCDMA: .via3G,
        CTRadioAccessTechnologyHSDPA: .via3G,
        CTRadioAccessTechnologyHSUPA: .via3G,
        CTRadioAccessTechnologyCDMA1x: .via3G,
        CTRadioAccessTechnologyCDMAEVDORev0: .via3G,
        CTRadioAccessTechnologyCDMAEVDORevA: .via3G,
        CTRadioAccessTechnologyCDMAEVDORevB: .via3G,
        CTRadioAccessTechnologyeHRPD: .via3G,
        CTRadioAccessTechnologyLTE: .via4G
    ]
}

#endif
