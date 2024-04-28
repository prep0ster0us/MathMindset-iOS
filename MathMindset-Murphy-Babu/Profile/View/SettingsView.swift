import SwiftUI

struct SettingsView: View {
    @State var biometricEnabled     = true
    @State var darkModeEnabled      = true
    @State var notificationsEnabled = true

    var body: some View {
        VStack {
            Image("SettingsPage")
                .resizable()
                .frame(width: 150, height: 150)
                .padding(.bottom, 36)
            VStack (spacing: 12) {
                SettingItem(text: "Enable Notifications", settingEnabled: $notificationsEnabled)
                SettingItem(text: "Enable Biometric Login", settingEnabled: $biometricEnabled)
                SettingItem(text: "Enable Dark mode", settingEnabled: $darkModeEnabled)
            }
            Spacer()
        }
    }
}

struct SettingItem: View {
    let text : String
    @Binding var settingEnabled: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: $settingEnabled, label: {
                Text(text)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.textTint)
            })
            .padding()
            .toggleStyle(SwitchToggleStyle(tint: Color(.systemTeal)))
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.bgContrast.opacity(0.2), lineWidth: 1.2)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    SettingsView()
}
