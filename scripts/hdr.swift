import Cocoa

extension NSDeviceDescriptionKey {
    static let screenNumber = NSDeviceDescriptionKey("NSScreenNumber")
}

extension NSScreen {

    public var displayID: CGDirectDisplayID {
        get {
            return deviceDescription[.screenNumber] as? CGDirectDisplayID ?? 0
        }
    }

    public var displayName: String? {
        get {
            var name: String? = nil
            var object: io_object_t
            var iter = io_iterator_t()
            let matching = IOServiceMatching("IODisplayConnect")
            let result = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iter)

            if result != KERN_SUCCESS || iter == 0 { return nil }

            repeat {
                object = IOIteratorNext(iter)
                if let info = IODisplayCreateInfoDictionary(object, IOOptionBits(kIODisplayOnlyPreferredName)).takeRetainedValue() as? [String:AnyObject],
                    (info[kDisplayVendorID] as? UInt32 == CGDisplayVendorNumber(displayID) &&
                    info[kDisplayProductID] as? UInt32 == CGDisplayModelNumber(displayID) &&
                    info[kDisplaySerialNumber] as? UInt32 ?? 0 == CGDisplaySerialNumber(displayID))
                {
                    if let productNames = info["DisplayProductName"] as? [String:String],
                       let productName = productNames.first?.value
                    {
                        name = productName
                        break
                    }
                }
            } while object != 0

            IOObjectRelease(iter)
            return name
        }
    }
}

class App: NSApplication, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        atexit_b { NSApp.setActivationPolicy(.prohibited) }
        NSApp.activate(ignoringOtherApps: true)

        for screen in NSScreen.screens {
            var maxPot: CGFloat = -1.0
            var maxRef: CGFloat = -1.0
            var maxRange: CGFloat = -1.0

            print("-----------------------------------------------------------------------------")
            print(screen.displayName ?? "unknown")

            if #available(macOS 10.15, *) {
                maxPot = screen.maximumPotentialExtendedDynamicRangeColorComponentValue
                maxRef = screen.maximumReferenceExtendedDynamicRangeColorComponentValue
            }
            maxRange = screen.maximumExtendedDynamicRangeColorComponentValue

            print("maximumPotentialExtendedDynamicRangeColorComponentValue: \(maxPot)")
            print("maximumReferenceExtendedDynamicRangeColorComponentValue: \(maxRef)")
            print("maximumExtendedDynamicRangeColorComponentValue: \(maxRange)")
            print("-----------------------------------------------------------------------------")
        }

        exit(1)
    }
}

let app = App.shared
NSApp = app
app.delegate = app as? NSApplicationDelegate
app.run()