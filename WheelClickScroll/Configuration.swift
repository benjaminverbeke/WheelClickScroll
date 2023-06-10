import Cocoa

class Configuration {
    static let shared: Configuration = Configuration()
    
    let defaultMaxScrollDelay: Double = 4
    let defaultMinScrollDelay: Double = 0.15
    let defaultDeadZoneRadius: Double = 20
    
    // The bigger the factor the quicker you reach max speed
    let maxPixelDistanceFactor: CGFloat = 5
    
    var isScrollInverted: Bool = UserDefaults.standard.bool(forKey: "com.apple.swipescrolldirection") ? true : false
    
    var deadZoneRadius: Double {
        didSet {
            UserDefaults.standard.set(deadZoneRadius, forKey: "DeadZoneRadius")
        }
    }
    
    var maxScrollDelay: Double {
        didSet {
            UserDefaults.standard.set(maxScrollDelay, forKey: "MaxScrollDelay")
        }
    }
    
    var minScrollDelay: Double {
        didSet {
            UserDefaults.standard.set(minScrollDelay, forKey: "MinScrollDelay")
        }
    }
    
    private init() {
        // Load values from UserDefaults
        let savedMaxDelay = UserDefaults.standard.object(forKey: "MaxScrollDelay") as? Double
        let savedMinDelay = UserDefaults.standard.object(forKey: "MinScrollDelay") as? Double
        let savedDeadZoneRadius = UserDefaults.standard.object(forKey: "DeadZoneRadius") as? Double
        
        if savedMaxDelay != nil && savedMaxDelay != 0 {
            maxScrollDelay = savedMaxDelay!
        } else {
            maxScrollDelay = defaultMaxScrollDelay
        }
        
        if savedMinDelay != nil && savedMinDelay != 0 {
            minScrollDelay = savedMinDelay!
        } else {
            minScrollDelay = defaultMinScrollDelay
        }
        
        if savedDeadZoneRadius != nil && savedDeadZoneRadius != 0 {
            deadZoneRadius = savedDeadZoneRadius!
        } else {
            deadZoneRadius = defaultDeadZoneRadius
        }
    }
}
