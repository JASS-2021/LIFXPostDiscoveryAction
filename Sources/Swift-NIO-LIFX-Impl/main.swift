import Foundation
import ArgumentParser

struct NIOLIFXImpl: ParsableCommand {
    @Argument(help: "The directory the file should be saved at")
    var filePath: String = Bundle.main.bundlePath
    
    @Option(help: "The file name")
    var fileName: String = "lifx_devices"
    
    @Option(help: "On this network interface the discovery is run.")
    var networkInterface: String = "wlan0"
    
    func run() throws {
        let impl = _NIOLIFXImpl(fileName: fileName,
                                filePath: URL(fileURLWithPath: filePath),
                                specifiedNetworkInterface: networkInterface)
        try impl.run()
    }
}

NIOLIFXImpl.main()
