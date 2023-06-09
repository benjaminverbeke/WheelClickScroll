import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var preferencesWindow: NSWindow?
    
    let defaultMaxScrollDelay: Double = 150
    let defaultMinScrollDelay: Double = 30
    
    var maxScrollDelay: Double = 0.01 {
        didSet {
            UserDefaults.standard.set(maxScrollDelay, forKey: "MaxScrollDelay")
            mouseClickService?.maxScrollDelay = maxScrollDelay
        }
    }
    
    var minScrollDelay: Double = 0.01 {
        didSet {
            UserDefaults.standard.set(minScrollDelay, forKey: "MinScrollDelay")
            mouseClickService?.minScrollDelay = minScrollDelay
        }
    }
    
    var maxDelayTextField: NSTextField!
    var minDelayTextField: NSTextField!
    var maxDelaySlider: NSSlider!
    var minDelaySlider: NSSlider!
    
    var mouseClickService: MouseClickService? = nil
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load values from UserDefaults
        let savedMaxDelay = UserDefaults.standard.object(forKey: "MaxScrollDelay") as? Double
        let savedMinDelay = UserDefaults.standard.object(forKey: "MinScrollDelay") as? Double
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
        
        mouseClickService = MouseClickService(minDelay: minScrollDelay, maxDelay: maxScrollDelay)
        mouseClickService!.startMonitoring()
        
        if let button = statusItem.button {
            let myAttribute = [ NSAttributedString.Key.font: NSFont(name: "Arial", size: 15)]
            let myAttrString = NSAttributedString(string: String(format: "%C", 0x2195), attributes: myAttribute as [NSAttributedString.Key : Any])
            button.attributedTitle = myAttrString
            button.action = #selector(togglePopover(_:))
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        // Implement your popover behavior here
        // For example, display a custom view or perform an action
    }
    
    @objc func showPreferences(_ sender: AnyObject?) {
        if preferencesWindow == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 470, height: 200), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.center()
            window.title = "Preferences"
            window.isReleasedWhenClosed = false
            
            let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
            
            let maxDelayLabel = NSTextField(labelWithString: "Max. scroll delay:")
            maxDelayLabel.frame = NSRect(x: 20, y: 145, width: 150, height: 20)
            contentView.addSubview(maxDelayLabel)
            
            maxDelaySlider = NSSlider(value: maxScrollDelay, minValue: 0.01, maxValue: 300.0, target: self, action: #selector(maxDelaySliderChanged(_:)))
            maxDelaySlider.frame = NSRect(x: 180, y: 140, width: 200, height: 25)
            maxDelaySlider.isContinuous = true
            contentView.addSubview(maxDelaySlider)
            
            let minDelayLabel = NSTextField(labelWithString: "Min. scroll delay:")
            minDelayLabel.frame = NSRect(x: 20, y: 105, width: 150, height: 20)
            contentView.addSubview(minDelayLabel)
            
            minDelaySlider = NSSlider(value: minScrollDelay, minValue: 0.01, maxValue: 300.0, target: self, action: #selector(minDelaySliderChanged(_:)))
            minDelaySlider.frame = NSRect(x: 180, y: 100, width: 200, height: 25)
            minDelaySlider.isContinuous = true
            contentView.addSubview(minDelaySlider)
            
            maxDelayTextField = NSTextField(frame: NSRect(x: 400, y: 145, width: 50, height: 20))
            maxDelayTextField.stringValue = String(format: "%.2f", maxScrollDelay)
            maxDelayTextField.alignment = .center
            maxDelayTextField.delegate = self
            contentView.addSubview(maxDelayTextField)
            
            minDelayTextField = NSTextField(frame: NSRect(x: 400, y: 105, width: 50, height: 20))
            minDelayTextField.stringValue = String(format: "%.2f", minScrollDelay)
            minDelayTextField.alignment = .center
            minDelayTextField.delegate = self
            contentView.addSubview(minDelayTextField)
            
            window.contentView = contentView
            preferencesWindow = window
            preferencesWindow?.level = .floating
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func maxDelaySliderChanged(_ sender: NSSlider) {
        maxScrollDelay = sender.doubleValue
        if maxScrollDelay < minScrollDelay {
            maxScrollDelay = minScrollDelay
        }
        sender.doubleValue = maxScrollDelay
        updateMaxDelayTextField()
    }
    
    @objc func minDelaySliderChanged(_ sender: NSSlider) {
        minScrollDelay = sender.doubleValue
        if minScrollDelay > maxScrollDelay {
            minScrollDelay = maxScrollDelay
        }
        sender.doubleValue = minScrollDelay
        updateMinDelayTextField()
    }
    
    func updateMaxDelayTextField() {
        maxDelayTextField.stringValue = String(format: "%.2f", maxScrollDelay)
    }
    
    func updateMinDelayTextField() {
        minDelayTextField.stringValue = String(format: "%.2f", minScrollDelay)
    }
    
    @objc func maxDelayTextFieldChanged(_ sender: NSTextField) {
        if let value = Double(sender.stringValue) {
            maxScrollDelay = value
            if maxScrollDelay < minScrollDelay {
                maxScrollDelay = minScrollDelay
                sender.stringValue = String(format: "%.2f", maxScrollDelay)
            }
            maxDelaySlider.doubleValue = maxScrollDelay
        } else {
            sender.stringValue = String(format: "%.2f", maxScrollDelay)
        }
    }
    
    @objc func minDelayTextFieldChanged(_ sender: NSTextField) {
        if let value = Double(sender.stringValue) {
            minScrollDelay = value
            if minScrollDelay > maxScrollDelay {
                minScrollDelay = maxScrollDelay
                sender.stringValue = String(format: "%.2f", minScrollDelay)
            }
            self.minDelaySlider.doubleValue = minScrollDelay
        } else {
            sender.stringValue = String(format: "%.2f", minScrollDelay)
        }
    }
}

extension AppDelegate: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            return
        }
        
        if textField === maxDelayTextField {
            maxDelayTextFieldChanged(textField)
        } else if textField === minDelayTextField {
            minDelayTextFieldChanged(textField)
        }
    }
}

let app = NSApplication.shared

let delegate = AppDelegate()
app.delegate = delegate

app.run()
