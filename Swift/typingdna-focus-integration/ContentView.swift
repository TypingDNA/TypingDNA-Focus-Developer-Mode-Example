import SwiftUI
import Foundation

struct TypingDNAFocusMoods {
    var focused: Double?
    var stressed: Double?
    var tired: Double?
    var happy: Double?
    var calm: Double?
    var energetic: Double?
}

struct TypingDNAFocusActivity {
    var minutes: Int
    var chars: Int
    var cpm: Int
}

struct TypingDNAFocusData {
    var time: String
    var version: String
    var moods: TypingDNAFocusMoods
    var activity: TypingDNAFocusActivity
}

extension TypingDNAFocusData {
    init?(json: [String: Any]) {
        let data = json["TypingDNA"] as? [String: Any]
        let moods = data?["moods"] as? [String: Any]
        let activity = data?["activity"] as? [String: Any]
        
        self.time = data?["time"] as? String ?? ""
        self.version = data?["version"] as? String ?? ""
        self.moods = TypingDNAFocusMoods()
        self.moods.focused = moods?["focused"] as? Double
        self.moods.stressed = moods?["stressed"] as? Double
        self.moods.tired = moods?["tired"] as? Double
        self.moods.happy = moods?["happy"] as? Double
        self.moods.calm = moods?["calm"] as? Double
        self.moods.energetic = moods?["energetic"] as? Double
        self.activity = TypingDNAFocusActivity(minutes: 0, chars: 0, cpm: 0)
        self.activity.minutes = activity?["minutes"] as? Int ?? 0
        self.activity.chars = activity?["chars"] as? Int ?? 0
        self.activity.cpm = activity?["cpm"] as? Int ?? 0
    }
}

class TypingDNAFocus: ObservableObject {
    @Published var focusData: TypingDNAFocusData?
}

class TypingDNAObserver {
    var focus: TypingDNAFocus
    
    init(focus: TypingDNAFocus) {
        self.focus = focus
        let center = DistributedNotificationCenter.default()
        center.addObserver(self, selector: #selector(self.onOneHourPassed), name: NSNotification.Name("TypingDNAFocus"), object: nil)
    }
    
    @objc private func onOneHourPassed(notification: NSNotification) {
        print(notification)
        let payload = notification.userInfo?["payload"] as! String
        let json = try? JSONSerialization.jsonObject(with: payload.data(using: String.Encoding.utf8)!, options: []) as? [String: AnyObject]
        if json != nil {
            focus.focusData = TypingDNAFocusData(json: json!)!
        }
    }
}

struct Property: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).padding()
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var focus: TypingDNAFocus
    var observer: TypingDNAObserver
    
    var body: some View {
        VStack {
            Property(label: "App version:", value: focus.focusData?.version ?? "")
            Property(label: "Time (UTC):", value: focus.focusData?.time ?? "")
            Spacer()
            Text("Moods: ")
            HStack {
                Property(label: "Focused:", value: focus.focusData?.moods.focused?.description ?? "N/A")
                Property(label: "Stressed:", value: focus.focusData?.moods.stressed?.description ?? "N/A")
                Property(label: "Tired:", value: focus.focusData?.moods.tired?.description ?? "N/A")
            }
            HStack {
                Property(label: "Happy:", value: focus.focusData?.moods.happy?.description ?? "N/A")
                Property(label: "Calm:", value: focus.focusData?.moods.calm?.description ?? "N/A")
                Property(label: "Energetic:", value: focus.focusData?.moods.energetic?.description ?? "N/A")
            }
            Spacer()
            Text("Activity: ")
            HStack {
                Property(label: "Minutes spent typing:", value: focus.focusData?.activity.minutes.description ?? "N/A")
                Property(label: "Characters typed:", value: focus.focusData?.activity.chars.description ?? "N/A")
                Property(label: "Characters per minute:", value: focus.focusData?.activity.cpm.description ?? "N/A")
            }
        }.frame(
            minWidth: 300,
            maxWidth: .infinity,
            minHeight: 300,
            maxHeight: 300,
            alignment: .topLeading
        )
    }
}
