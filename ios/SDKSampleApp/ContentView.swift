import SwiftUI
import LiveVoiceSDK

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("logo")
                        .padding(.top)
                    Text("LiveVoice SDK Demo")
                        .fontWeight(.semibold)
                        .padding()
                }
                List {
                    NavigationLink("Default UserInterface") {
                        DefaultUI()
                    }
                    NavigationLink("Custom UserInterface") {
                        CustomUI()
                    }
                    NavigationLink("Custom UserInterface 2") {
                        CustomUI2()
                    }
                }
            }
        }
    }
}

#Preview("Full customization") {
    ContentView()
        .initialized(joinCode: "123456", apiKey: "s09WEG5y3caQ6R2PDaG4i8R1aTooTd")
}

#Preview("Hide Branding") {
    ContentView()
        .initialized(joinCode: "123456", apiKey: "uFlkcGkUJEcb7jK6qFcdygreFRTXVh")
}

#Preview("Default") {
    ContentView()
        .initialized(joinCode: "123456", apiKey: "HD4cQklUOQKOBWimG54j2kRnxFklDL")
}
