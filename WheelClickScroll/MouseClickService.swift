import Cocoa

class MouseClickService: NSObject {
    let minimalPixelDistanceDelta: CGFloat = 5
    var maxScrollDelay: CGFloat = 150
    var minScrollDelay: CGFloat = 30

    // The bigger the factor the quicker you reach max speed
    let maxPixelDistanceFactor: CGFloat = 5

    var scrollDelay: CGFloat
    
    var _scrollModeEnabled:Bool = false
    var scrollModeEnabled:Bool {
        get{
            return self._scrollModeEnabled
        }
        set(newValue){
            self._scrollModeEnabled = newValue
            self.log(message: "Scroll Mode: \(self.scrollModeEnabled ? "Enabled" : "Disabled")")
        }
    }
    
    var initialMouseY: CGFloat = 0.0
    var currentMouseY: CGFloat = 0.0
    var currentScreenHeight: CGFloat? = 0.0
    var isScrollInverted = UserDefaults.standard.bool(forKey: "com.apple.swipescrolldirection") ? true : false
    
    init(minDelay: Double, maxDelay: Double) {
        minScrollDelay = minDelay
        maxScrollDelay = maxDelay
        scrollDelay = minScrollDelay
    }
    
    func startMonitoring() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .otherMouseUp, .mouseMoved]) { event in
            if event.type == .otherMouseDown {
                if event.buttonNumber == 2 {
                    // Toggle "scrollMode" on or off
                    self.scrollModeEnabled.toggle()

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

                usleep(UInt32(self.scrollDelay * 1000))
            }
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

        self.scrollDelay = maxScrollDelay - (maxScrollDelay - minScrollDelay) * pixelRatio
    }

    func scrollPage(deltaY: CGFloat) {
        var isUp = deltaY > 0

        if isScrollInverted {
            isUp = !isUp
        }

        let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: (isUp ? 1 : -1), wheel2: 0, wheel3: 0)
        //let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: Int32(deltaY), wheel2: 0, wheel3: 0)
        log(message: "Scrolling \(deltaY > 0 ? "Up" : "Down") by 1 pixel per \(scrollDelay)s - deltaY = \(deltaY)")
        scrollEvent?.post(tap: .cghidEventTap)
        updateScrollTimerInterval(deltaY: deltaY)
    }

    func log(message: String) {
#if DEBUG
        print(message)
#endif
    }
}
