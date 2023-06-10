import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {    
    var mouseClickService: MouseClickService? = nil
    var menu: Menu!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        menu = Menu()
        mouseClickService = MouseClickService()
        mouseClickService!.startMonitoring()
    }
}

let app = NSApplication.shared

let delegate = AppDelegate()
app.delegate = delegate

app.run()
