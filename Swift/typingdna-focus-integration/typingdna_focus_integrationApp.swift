import SwiftUI

@main
struct typingdna_focus_integrationApp: App {
    var body: some Scene {
        let focus = TypingDNAFocus()
        let observer = TypingDNAObserver(focus: focus)
        WindowGroup {
            ContentView(observer: observer).environmentObject(focus)
        }
    }
}
