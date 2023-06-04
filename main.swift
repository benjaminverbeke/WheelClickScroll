import Cocoa

class MouseClickService: NSObject {
    let minimalPixelDistanceDelta: CGFloat = 15
    let minScrollFrequency: CGFloat = 4
    let maxScrollFrequency: CGFloat = 0.5
    
    // The bigger the factor the quicker you reach max speed
    let maxPixelDistanceFactor: CGFloat = 5
    
    var scrollFrequency: CGFloat = 4
    var scrollModeEnabled = false
    var initialMouseY: CGFloat = 0.0
    var currentMouseY: CGFloat = 0.0
    var currentScreenHeight: CGFloat? = 0.0
    var isScrollInverted = UserDefaults.standard.bool(forKey: "com.apple.swipescrolldirection") ? true : false

    func startMonitoring() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .otherMouseUp, .mouseMoved]) { event in
            if event.type == .otherMouseDown {
                if event.buttonNumber == 2 {
                    // Toggle "scrollMode" on or off
                    self.scrollModeEnabled.toggle()
                    print("Scroll Mode: \(self.scrollModeEnabled ? "Enabled" : "Disabled")")

                    if self.scrollModeEnabled {
                        self.initialMouseY = event.locationInWindow.y
                        self.currentMouseY = event.locationInWindow.y
                        self.currentScreenHeight = NSScreen.main?.frame.height
                        self.isScrollInverted = UserDefaults.standard.bool(forKey: "com.apple.swipescrolldirection") ? true : false
                        self.startMoveMonitoring()
                    }
                }
            }
            
            if (!self.scrollModeEnabled) {
                return
            }
            
            if event.type == .mouseMoved {
                self.currentMouseY = event.locationInWindow.y
            } else if event.type == .leftMouseDown || event.type == .rightMouseDown {
                self.scrollModeEnabled = false
            }
        }
    }
    
    func startMoveMonitoring() {
        DispatchQueue.global(qos: .userInitiated).async {
            while (self.scrollModeEnabled) {
                let deltaY = self.currentMouseY - self.initialMouseY
                
                if abs(deltaY) > self.minimalPixelDistanceDelta {
                    self.scrollPage(deltaY: deltaY)
                }
                
                usleep(UInt32(self.scrollFrequency * 1000))
            }

//            DispatchQueue.main.async {
//                print("This is run on the main queue, after the previous code in outer block")
//            }
        }
    }
    
    func updateScrollTimerInterval(deltaY: CGFloat) {
        if (self.currentScreenHeight == nil) {
            return
        }
        let maxPixelDistance = self.currentScreenHeight! / self.maxPixelDistanceFactor
        var pixelRatio: CGFloat = abs(deltaY) / maxPixelDistance
        if (pixelRatio > 1) {
            pixelRatio = 1
        }
        
        self.scrollFrequency = minScrollFrequency - (minScrollFrequency - maxScrollFrequency) * pixelRatio
    }

    func scrollPage(deltaY: CGFloat) {
        var isUp = deltaY > 0
        
        if isScrollInverted {
            isUp = !isUp
        }
        
        let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: (isUp ? 1 : -1), wheel2: 0, wheel3: 0)
        //let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: Int32(deltaY), wheel2: 0, wheel3: 0)
        print("Scrolling \(deltaY > 0 ? "Up" : "Down") by 1 pixel at \(scrollFrequency) scroll/s - deltaY = \(deltaY)")
        scrollEvent?.post(tap: .cghidEventTap)
        updateScrollTimerInterval(deltaY: deltaY)
    }
}

let mouseClickService = MouseClickService()
mouseClickService.startMonitoring()

// Prevent the application from quitting immediately
NSApplication.shared.run()
