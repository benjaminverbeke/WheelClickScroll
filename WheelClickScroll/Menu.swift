import Cocoa

class Menu : NSObject {
    let configuration = Configuration.shared
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    var preferencesWindow: NSWindow?
    
    var maxDelayTextField: NSTextField!
    var minDelayTextField: NSTextField!
    var deadZoneRadiusTextField: NSTextField!
    var maxDistancePercentTextField: NSTextField!
    
    var maxDelaySlider: NSSlider!
    var minDelaySlider: NSSlider!
    var deadZoneRadiusSlider: NSSlider!
    var maxDistancePercentSlider: NSSlider!
    var invertScrollCheckBox: NSButton!
    
    override init() {
        super.init()
        if let button = statusItem.button {
            let myAttribute = [ NSAttributedString.Key.font: NSFont(name: "Arial", size: 15)]
            let myAttrString = NSAttributedString(string: String(format: "%C", 0x2195), attributes: myAttribute as [NSAttributedString.Key : Any])
            button.attributedTitle = myAttrString
            //button.action = #selector(togglePopover(_:))
        }
        
        let menu = NSMenu()
        let showPreferencesIntem = NSMenuItem(title: "Preferences", action: #selector(showPreferences(_:)), keyEquivalent: "")
        showPreferencesIntem.target = self
        menu.addItem(showPreferencesIntem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
//    @objc func togglePopover(_ sender: AnyObject?) {
//        // Implement your popover behavior here
//        // For example, display a custom view or perform an action
//    }
    
    @objc func showPreferences(_ sender: AnyObject?) {
        if preferencesWindow == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 470, height: 300), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.center()
            window.title = "Preferences"
            window.isReleasedWhenClosed = false
            
            let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
            
            let maxDelayLabel = NSTextField(labelWithString: "Max. scroll delay:")
            maxDelayLabel.frame = NSRect(x: 20, y: 225, width: 150, height: 20)
            contentView.addSubview(maxDelayLabel)
            
            maxDelaySlider = NSSlider(value: self.configuration.maxScrollDelay, minValue: 0.01, maxValue: 200.0, target: self, action: #selector(maxDelaySliderChanged(_:)))
            maxDelaySlider.frame = NSRect(x: 180, y: 220, width: 200, height: 25)
            maxDelaySlider.numberOfTickMarks = 20
            contentView.addSubview(maxDelaySlider)
            
            let minDelayLabel = NSTextField(labelWithString: "Min. scroll delay:")
            minDelayLabel.frame = NSRect(x: 20, y: 185, width: 150, height: 20)
            contentView.addSubview(minDelayLabel)
            
            minDelaySlider = NSSlider(value: self.configuration.minScrollDelay, minValue: 0.01, maxValue: 200.0, target: self, action: #selector(minDelaySliderChanged(_:)))
            minDelaySlider.frame = NSRect(x: 180, y: 180, width: 200, height: 25)
            minDelaySlider.numberOfTickMarks = 20
            contentView.addSubview(minDelaySlider)
            
            maxDelayTextField = NSTextField(frame: NSRect(x: 400, y: 225, width: 50, height: 20))
            maxDelayTextField.stringValue = String(format: "%.2f", self.configuration.maxScrollDelay)
            maxDelayTextField.alignment = .center
            maxDelayTextField.delegate = self
            contentView.addSubview(maxDelayTextField)
            
            minDelayTextField = NSTextField(frame: NSRect(x: 400, y: 185, width: 50, height: 20))
            minDelayTextField.stringValue = String(format: "%.2f", self.configuration.minScrollDelay)
            minDelayTextField.alignment = .center
            minDelayTextField.delegate = self
            contentView.addSubview(minDelayTextField)
            
            let deadZoneRadiusLabel = NSTextField(labelWithString: "Dead zone radius:")
            deadZoneRadiusLabel.frame = NSRect(x: 20, y: 145, width: 150, height: 20)
            contentView.addSubview(deadZoneRadiusLabel)
            
            deadZoneRadiusSlider = NSSlider(value: self.configuration.deadZoneRadius, minValue: 1, maxValue: 50, target: self, action: #selector(maxDeadZoneRadiusSliderChanged(_:)))
            deadZoneRadiusSlider.frame = NSRect(x: 180, y: 140, width: 200, height: 25)
            deadZoneRadiusSlider.numberOfTickMarks = 20
            contentView.addSubview(deadZoneRadiusSlider)
            
            deadZoneRadiusTextField = NSTextField(frame: NSRect(x: 400, y: 145, width: 50, height: 20))
            deadZoneRadiusTextField.stringValue = String(format: "%.2f", self.configuration.deadZoneRadius)
            deadZoneRadiusTextField.alignment = .center
            deadZoneRadiusTextField.delegate = self
            contentView.addSubview(deadZoneRadiusTextField)
            
            let maxDistancePercentLabel = NSTextField(labelWithString: "Distance for max. speed:")
            maxDistancePercentLabel.frame = NSRect(x: 20, y: 105, width: 150, height: 20)
            contentView.addSubview(maxDistancePercentLabel)
            
            maxDistancePercentSlider = NSSlider(value: self.configuration.maxDistancePercent, minValue: 1, maxValue: 100, target: self, action: #selector(maxDistancePercentSliderChanged(_:)))
            maxDistancePercentSlider.frame = NSRect(x: 180, y: 100, width: 200, height: 25)
            maxDistancePercentSlider.numberOfTickMarks = 20
            contentView.addSubview(maxDistancePercentSlider)
            
            maxDistancePercentTextField = NSTextField(frame: NSRect(x: 400, y: 105, width: 50, height: 20))
            maxDistancePercentTextField.stringValue = String(format: "%.2f", self.configuration.maxDistancePercent)
            maxDistancePercentTextField.alignment = .center
            maxDistancePercentTextField.delegate = self
            contentView.addSubview(maxDistancePercentTextField)
            
            window.contentView = contentView
            preferencesWindow = window
            preferencesWindow?.level = .floating
        }
        
        // To make sure the window appears in front
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func maxDelaySliderChanged(_ sender: NSSlider) {
        self.configuration.maxScrollDelay = sender.doubleValue
        if self.configuration.maxScrollDelay < self.configuration.minScrollDelay {
            self.configuration.maxScrollDelay = self.configuration.minScrollDelay
        }
        sender.doubleValue = self.configuration.maxScrollDelay
        updateMaxDelayTextField()
    }
    
    @objc func minDelaySliderChanged(_ sender: NSSlider) {
        self.configuration.minScrollDelay = sender.doubleValue
        if self.configuration.minScrollDelay > self.configuration.maxScrollDelay {
            self.configuration.minScrollDelay = self.configuration.maxScrollDelay
        }
        sender.doubleValue = self.configuration.minScrollDelay
        updateMinDelayTextField()
    }
    
    @objc func maxDeadZoneRadiusSliderChanged(_ sender: NSSlider) {
        self.configuration.deadZoneRadius = sender.doubleValue
        updateDeadZoneTextField()
    }
    
    @objc func maxDistancePercentSliderChanged(_ sender: NSSlider) {
        self.configuration.maxDistancePercent = sender.doubleValue
        updateMaxDistancePercentTextField()
    }
    
    func updateMaxDistancePercentTextField() {
        maxDistancePercentTextField.stringValue = String(format: "%.2f", self.configuration.maxDistancePercent)
    }
    
    func updateDeadZoneTextField() {
        deadZoneRadiusTextField.stringValue = String(format: "%.2f", self.configuration.deadZoneRadius)
    }
    
    func updateMaxDelayTextField() {
        maxDelayTextField.stringValue = String(format: "%.2f", self.configuration.maxScrollDelay)
    }
    
    func updateMinDelayTextField() {
        minDelayTextField.stringValue = String(format: "%.2f", self.configuration.minScrollDelay)
    }
    
    @objc func maxDelayTextFieldChanged(_ sender: NSTextField) {
        if let value = Double(sender.stringValue) {
            self.configuration.maxScrollDelay = value
            if self.configuration.maxScrollDelay < self.configuration.minScrollDelay {
                self.configuration.maxScrollDelay = self.configuration.minScrollDelay
                sender.stringValue = String(format: "%.2f", self.configuration.maxScrollDelay)
            }
            maxDelaySlider.doubleValue = self.configuration.maxScrollDelay
        } else {
            sender.stringValue = String(format: "%.2f", self.configuration.maxScrollDelay)
        }
    }
    
    @objc func minDelayTextFieldChanged(_ sender: NSTextField) {
        if let value = Double(sender.stringValue) {
            self.configuration.minScrollDelay = value
            if self.configuration.minScrollDelay > self.configuration.maxScrollDelay {
                self.configuration.minScrollDelay = self.configuration.maxScrollDelay
                sender.stringValue = String(format: "%.2f", self.configuration.minScrollDelay)
            }
            self.minDelaySlider.doubleValue = self.configuration.minScrollDelay
        } else {
            sender.stringValue = String(format: "%.2f", self.configuration.minScrollDelay)
        }
    }
    
    @objc func deadZoneRadiusTextFieldChanged(_ sender: NSTextField) {
        if let value = Double(sender.stringValue) {
            if (value > deadZoneRadiusSlider.maxValue) {
                self.configuration.deadZoneRadius = deadZoneRadiusSlider.maxValue
                sender.stringValue = String(format: "%.2f", self.configuration.deadZoneRadius)
            }
            else if (value < deadZoneRadiusSlider.minValue) {
                self.configuration.deadZoneRadius = deadZoneRadiusSlider.minValue
                sender.stringValue = String(format: "%.2f", self.configuration.deadZoneRadius)
            }
            else {
                self.configuration.deadZoneRadius = value
            }
            self.deadZoneRadiusSlider.doubleValue = self.configuration.deadZoneRadius
        }
        else {
            sender.stringValue = String(format: "%.2f", self.configuration.deadZoneRadius)
        }
    }
    
    @objc func maxDistancePercentTextFieldChanged(_ sender: NSTextField) {
        if let value = Double(sender.stringValue) {
            if (value > maxDistancePercentSlider.maxValue) {
                self.configuration.maxDistancePercent = maxDistancePercentSlider.maxValue
                sender.stringValue = String(format: "%.2f", self.configuration.maxDistancePercent)
            }
            else if (value < maxDistancePercentSlider.minValue) {
                self.configuration.maxDistancePercent = maxDistancePercentSlider.minValue
                sender.stringValue = String(format: "%.2f", self.configuration.maxDistancePercent)
            }
            else {
                self.configuration.maxDistancePercent = value
            }
            self.maxDistancePercentSlider.doubleValue = self.configuration.maxDistancePercent
        }
        else {
            sender.stringValue = String(format: "%.2f", self.configuration.maxDistancePercent)
        }
    }
}

extension Menu: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            return
        }
        
        if textField === maxDelayTextField {
            maxDelayTextFieldChanged(textField)
        } else if textField === minDelayTextField {
            minDelayTextFieldChanged(textField)
        } else if textField === deadZoneRadiusTextField {
            deadZoneRadiusTextFieldChanged(textField)
        } else if textField === maxDistancePercentTextField {
            maxDistancePercentTextFieldChanged(textField)
        }
    }
}
