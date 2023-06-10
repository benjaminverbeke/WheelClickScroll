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
    var reverseScrollingCheckBox: NSButton!
    
    let statusItemAttribute = [ NSAttributedString.Key.font: NSFont(name: "Arial", size: 15)]
    let descriptionAttribute = [ NSAttributedString.Key.font: NSFont(name: "Arial", size: 12), NSAttributedString.Key.foregroundColor: NSColor.lightGray]
    
    override init() {
        super.init()
        if let button = statusItem.button {
            button.attributedTitle = NSAttributedString(string: String(format: "%C", 0x2195),
                attributes: statusItemAttribute as [NSAttributedString.Key : Any])
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
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 470, height: 450), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.center()
            window.title = "Preferences"
            window.isReleasedWhenClosed = false
            
            let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
            
            let maxDelayLabel = NSTextField(labelWithString: "Max. scroll delay:")
            maxDelayLabel.frame = NSRect(x: 20, y: 385, width: 150, height: 20)
            contentView.addSubview(maxDelayLabel)
            
            let maxDelayDescriptionLabel = NSTextField(labelWithAttributedString: NSAttributedString(string: "Maximum delay (seconds) between 2 wheel scrolls. Increase this value to reduce the initial speed when scrolling starts. Default: \(self.configuration.defaultMaxScrollDelay)",
                attributes: descriptionAttribute as [NSAttributedString.Key : Any]) )
            
            maxDelayDescriptionLabel.usesSingleLineMode = false
            maxDelayDescriptionLabel.cell?.wraps = true
            maxDelayDescriptionLabel.cell?.isScrollable = false
            maxDelayDescriptionLabel.frame = NSRect(x: 20, y: 325, width: 400, height: 50)
            contentView.addSubview(maxDelayDescriptionLabel)
            
            maxDelaySlider = NSSlider(value: self.configuration.maxScrollDelay, minValue: 0.01, maxValue: 200.0, target: self, action: #selector(maxDelaySliderChanged(_:)))
            maxDelaySlider.frame = NSRect(x: 180, y: 380, width: 200, height: 25)
            maxDelaySlider.numberOfTickMarks = 20
            contentView.addSubview(maxDelaySlider)
            
            maxDelayTextField = NSTextField(frame: NSRect(x: 400, y: 385, width: 50, height: 20))
            maxDelayTextField.stringValue = String(format: "%.2f", self.configuration.maxScrollDelay)
            maxDelayTextField.alignment = .center
            maxDelayTextField.delegate = self
            contentView.addSubview(maxDelayTextField)
            
            let minDelayLabel = NSTextField(labelWithString: "Min. scroll delay:")
            minDelayLabel.frame = NSRect(x: 20, y: 305, width: 150, height: 20)
            contentView.addSubview(minDelayLabel)
            
            let minDelayDescriptionLabel = NSTextField(labelWithAttributedString: NSAttributedString(string: "Minimum delay (seconds) between 2 wheel scrolls. Increase this value to reduce the maximum reachable scrolling speed. Default: \(self.configuration.defaultMinScrollDelay)",
                attributes: descriptionAttribute as [NSAttributedString.Key : Any]) )
            
            minDelayDescriptionLabel.usesSingleLineMode = false
            minDelayDescriptionLabel.cell?.wraps = true
            minDelayDescriptionLabel.cell?.isScrollable = false
            minDelayDescriptionLabel.frame = NSRect(x: 20, y: 245, width: 400, height: 50)
            contentView.addSubview(minDelayDescriptionLabel)
            
            minDelaySlider = NSSlider(value: self.configuration.minScrollDelay, minValue: 0.01, maxValue: 200.0, target: self, action: #selector(minDelaySliderChanged(_:)))
            minDelaySlider.frame = NSRect(x: 180, y: 300, width: 200, height: 25)
            minDelaySlider.numberOfTickMarks = 20
            contentView.addSubview(minDelaySlider)
            
            minDelayTextField = NSTextField(frame: NSRect(x: 400, y: 305, width: 50, height: 20))
            minDelayTextField.stringValue = String(format: "%.2f", self.configuration.minScrollDelay)
            minDelayTextField.alignment = .center
            minDelayTextField.delegate = self
            contentView.addSubview(minDelayTextField)
            
            let deadZoneRadiusLabel = NSTextField(labelWithString: "Dead zone radius:")
            deadZoneRadiusLabel.frame = NSRect(x: 20, y: 225, width: 150, height: 20)
            contentView.addSubview(deadZoneRadiusLabel)
            
            let deadZoneRadiusDescriptionLabel = NSTextField(labelWithAttributedString: NSAttributedString(string: "Dead zone height (pixels). Increase this value to increase the minimal height before which scrolling is triggered. Default: \(self.configuration.defaultDeadZoneRadius)",
                attributes: descriptionAttribute as [NSAttributedString.Key : Any]) )
            
            deadZoneRadiusDescriptionLabel.usesSingleLineMode = false
            deadZoneRadiusDescriptionLabel.cell?.wraps = true
            deadZoneRadiusDescriptionLabel.cell?.isScrollable = false
            deadZoneRadiusDescriptionLabel.frame = NSRect(x: 20, y: 165, width: 400, height: 50)
            contentView.addSubview(deadZoneRadiusDescriptionLabel)
            
            deadZoneRadiusSlider = NSSlider(value: self.configuration.deadZoneRadius, minValue: 1, maxValue: 50, target: self, action: #selector(maxDeadZoneRadiusSliderChanged(_:)))
            deadZoneRadiusSlider.frame = NSRect(x: 180, y: 220, width: 200, height: 25)
            deadZoneRadiusSlider.numberOfTickMarks = 20
            contentView.addSubview(deadZoneRadiusSlider)
            
            deadZoneRadiusTextField = NSTextField(frame: NSRect(x: 400, y: 225, width: 50, height: 20))
            deadZoneRadiusTextField.stringValue = String(format: "%.2f", self.configuration.deadZoneRadius)
            deadZoneRadiusTextField.alignment = .center
            deadZoneRadiusTextField.delegate = self
            contentView.addSubview(deadZoneRadiusTextField)
            
            let maxDistancePercentLabel = NSTextField(labelWithString: "Distance for max. speed:")
            maxDistancePercentLabel.frame = NSRect(x: 20, y: 145, width: 150, height: 20)
            contentView.addSubview(maxDistancePercentLabel)
            
            let maxDistancePercentDescriptionLabel = NSTextField(labelWithAttributedString: NSAttributedString(string: "Distance (% screen height) to reach maximum scrolling speed. Increase this value to smoothen the scrolling acceleration. Default: \(self.configuration.defaultMaxDistancePercent)",
                attributes: descriptionAttribute as [NSAttributedString.Key : Any]) )
            
            maxDistancePercentDescriptionLabel.usesSingleLineMode = false
            maxDistancePercentDescriptionLabel.cell?.wraps = true
            maxDistancePercentDescriptionLabel.cell?.isScrollable = false
            maxDistancePercentDescriptionLabel.frame = NSRect(x: 20, y: 85, width: 400, height: 50)
            contentView.addSubview(maxDistancePercentDescriptionLabel)
            
            maxDistancePercentSlider = NSSlider(value: self.configuration.maxDistancePercent, minValue: 1, maxValue: 100, target: self, action: #selector(maxDistancePercentSliderChanged(_:)))
            maxDistancePercentSlider.frame = NSRect(x: 180, y: 140, width: 200, height: 25)
            maxDistancePercentSlider.numberOfTickMarks = 20
            contentView.addSubview(maxDistancePercentSlider)
            
            maxDistancePercentTextField = NSTextField(frame: NSRect(x: 400, y: 145, width: 50, height: 20))
            maxDistancePercentTextField.stringValue = String(format: "%.2f", self.configuration.maxDistancePercent)
            maxDistancePercentTextField.alignment = .center
            maxDistancePercentTextField.delegate = self
            contentView.addSubview(maxDistancePercentTextField)
            
            reverseScrollingCheckBox = NSButton(title: "Reverse scrolling", target: self, action: #selector(revertScrollingCheckBoxChanged(_:)))
            reverseScrollingCheckBox.state = self.configuration.reverseScrolling ? NSControl.StateValue.on : NSControl.StateValue.off
            reverseScrollingCheckBox.setButtonType(NSButton.ButtonType.switch)
            reverseScrollingCheckBox.frame = NSRect(x: 20, y: 65, width: 150, height: 20)
            contentView.addSubview(reverseScrollingCheckBox)
            
            let reverseScrollingDescriptionLabel = NSTextField(labelWithAttributedString: NSAttributedString(string: "Reverse the mouse wheel scrolling direction. Default: \(self.configuration.defaultReverseScrolling ? "enabled" : "disabled")",
                attributes: descriptionAttribute as [NSAttributedString.Key : Any]) )
            
            reverseScrollingDescriptionLabel.usesSingleLineMode = false
            reverseScrollingDescriptionLabel.cell?.wraps = true
            reverseScrollingDescriptionLabel.cell?.isScrollable = false
            reverseScrollingDescriptionLabel.frame = NSRect(x: 20, y: 5, width: 400, height: 50)
            contentView.addSubview(reverseScrollingDescriptionLabel)
            
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
    
    @objc func revertScrollingCheckBoxChanged(_ sender: NSButton) {
        self.configuration.reverseScrolling = reverseScrollingCheckBox.state == NSControl.StateValue.on
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
