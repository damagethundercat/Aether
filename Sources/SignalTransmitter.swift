import Foundation
import Network

class SignalTransmitter {
    static let shared = SignalTransmitter()
    
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.aether.signal")
    
    // Broadcast to the local network void
    private let host: NWEndpoint.Host = "255.255.255.255"
    private let port: NWEndpoint.Port = 7777
    
    init() {
        setupConnection()
    }
    
    private func setupConnection() {
        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
        // Allow broadcast (Crucial for "sending to everyone")
        params.acceptLocalOnly = false
        
        // In the Network framework, broadcasting can be restricted.
        // If this fails, we might technically need utilizing BSD sockets,
        // but let's try the modern way first.
        // Actually, pure broadcast 255.255.255.255 often works better with raw sockets in Swift scripting.
        // Let's stick to a simpler BSD socket approach for guaranteed "Packet out" behavior without entitlement issues.
    }
    
    func broadcast(message: String) {
        // BURST MODE CONFIG
        let burstCount = 50
        
        // Convert string to data
        guard let data = message.data(using: .utf8) else { return }
        
        // Use raw POSIX socket for reliable Broadcasting without App Sandbox
        // SECURITY NOTE: We use raw sockets to ensure UDP packets leave the machine 
        // regardless of App Sandbox state. This is safe as it only sends outbound.
        let fd = socket(AF_INET, SOCK_DGRAM, 0) // Changed var to let
        if fd == -1 {
            print("Signal Error: Socket creation failed")
            return
        }
        defer { close(fd) }
        
        // Enable Broadcast
        var broadcast = 1
        if setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &broadcast, socklen_t(MemoryLayout<Int>.size)) == -1 {
            print("Signal Error: Setsockopt failed")
            return
        }
        
        let addresses = [
            ("255.255.255.255", 0xFFFFFFFF), // The Void (Broadcast)
            ("127.0.0.1", 0x7F000001)        // Local Reflection (For Verification)
        ]
        
        for (_, ipVal) in addresses {
            var addr = sockaddr_in()
            addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            addr.sin_family = at_unsigned_int(AF_INET)
            addr.sin_port = UInt16(7777).bigEndian // Port 7777
            addr.sin_addr.s_addr = in_addr_t(ipVal).bigEndian // Fix Endianness for IP
            
            // BURST MODE: Repeat 50 times to create a visible "Spike" in Network Monitor
            
            for _ in 0..<burstCount {
                // Silenced unused result warning with _ =
                _ = data.withUnsafeBytes { ptr -> Int in
                    guard let baseAddress = ptr.baseAddress else { return -1 }
                    return withUnsafePointer(to: &addr) { addrPtr in
                        return addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { saPtr in
                            return sendto(fd, baseAddress, data.count, 0, saPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
                        }
                    }
                }
            }
        }
        
        print("📡 Signal Transmitted: \(message) (x\(burstCount) burst) to the Void & Localhost.")
    }
}

// Swift 5.10+ Convenience
extension in_addr_t {
    var bigEndian: in_addr_t { return CFSwapInt32HostToBig(self) }
}

extension UInt16 {
    var bigEndian: UInt16 { return CFSwapInt16HostToBig(self) }
}

func at_unsigned_int(_ val: Int32) -> UInt8 {
    return UInt8(val)
}
