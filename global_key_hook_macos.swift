
import Foundation

/************************
*    Global Variable    *
*************************/
var g_Key: Int64 = 0
var g_Mod: Int64 = 0
var g_Mod1: Int64 = 0

/*******************
*      KeyHook     *
********************/
func startKeyHook() {
	
	let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
	
	guard let eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .listenOnly,
	                                       eventsOfInterest: CGEventMask(eventMask), callback: fetchKeycode, userInfo: nil)
		else {
			print("Unable to create an event.")
			exit(1)
	}
	
	let loopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
	CFRunLoopAddSource(CFRunLoopGetCurrent(), loopSource, .commonModes)
	CGEvent.tapEnable(tap: eventTap, enable: true)
	CFRunLoopRun()
}

/// Callback for Keyboard Event
func fetchKeycode(proxy: CGEventTapProxy, eventType: CGEventType, event: CGEvent, voidPtr: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
	
	if eventType == CGEventType.tapDisabledByTimeout {
		
		CGEvent.tapEnable(tap: event as! CFMachPort, enable: true)
	}
	
	
// Fetch character keys
	if [CGEventType.keyDown].contains(eventType) {
		g_Key = event.getIntegerValueField(.keyboardEventKeycode)
		print("Key: \(g_Key)")
	}
// Fetch mod key
	if [CGEventType.flagsChanged].contains(eventType) {
		g_Mod = event.getIntegerValueField(.keyboardEventKeycode)
		print("Mod: \(g_Mod)")
		
	}
// Control + p [Exit]
	else if g_Mod == 59 && g_Key == 35 {
		print("\(g_Mod) + \(g_Key) - Exited")
		exit(1)
	}
	
	g_Key = 0
	
	return Unmanaged.passRetained(event)
}


class ViewController: NSViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()

		DispatchQueue.global(qos: .default).async {
			startKeyHook()
		}
	}
}

