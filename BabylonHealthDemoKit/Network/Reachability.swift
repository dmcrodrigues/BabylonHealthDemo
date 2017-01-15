import Foundation
import ReactiveSwift
import Result
import SystemConfiguration

public protocol ReachabilityProtocol {

    func isReachable() -> SignalProducer<Bool, NoError>
}

// Highly based on: https://github.com/MailOnline/Reactor
public class Reachability: ReachabilityProtocol {

    public init() {}

    public func isReachable() -> SignalProducer<Bool, NoError> {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return SignalProducer(value: false)
        }

        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return SignalProducer(value: false)
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return SignalProducer(value: isReachable && !needsConnection)
    }
}
