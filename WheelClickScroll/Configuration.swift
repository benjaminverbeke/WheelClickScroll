import Cocoa

class Configuration {
    static let shared: Configuration = Configuration()
    
    let defaultMaxScrollDelay: Double = 4
    let defaultMinScrollDelay: Double = 0.15
    let defaultDeadZoneRadius: Double = 20
    let defaultMaxDistancePercent: Double = 20
    let defaultReverseScrolling: Bool = false
    
    var maxDistancePercent: Double {
        didSet {
            UserDefaults.standard.set(maxDistancePercent, forKey: "MaxSpeedDistance")
        }
    }
    
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
    
    var reverseScrolling: Bool {
        didSet {
            UserDefaults.standard.set(reverseScrolling, forKey: "ReverseScrolling")
        }
    }
    
    private init() {
        // Load values from UserDefaults
        let savedMaxDelay = UserDefaults.standard.object(forKey: "MaxScrollDelay") as? Double
        let savedMinDelay = UserDefaults.standard.object(forKey: "MinScrollDelay") as? Double
        let savedDeadZoneRadius = UserDefaults.standard.object(forKey: "DeadZoneRadius") as? Double
        let savedMaxDistancePercent = UserDefaults.standard.object(forKey: "MaxSpeedDistance") as? Double
        let savedReverseScrolling = UserDefaults.standard.object(forKey: "ReverseScrolling")
        
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
        
        if savedMaxDistancePercent != nil && savedMaxDistancePercent != 0 {
            maxDistancePercent = savedMaxDistancePercent!
        } else {
            maxDistancePercent = defaultMaxDistancePercent
        }
        
        if savedReverseScrolling != nil {
            reverseScrolling = savedReverseScrolling as! Bool
        } else {
            reverseScrolling = defaultReverseScrolling
        }
    }
}
