
import SwiftUI
// 设置页面
struct SettingsView: View {
    @State private var dailyGoal = 25
    @State private var enableNotifications = true
    @State private var studyReminder = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("学习设置") {
                    HStack {
                        Text("每日目标")
                        Spacer()
                        Stepper("\(dailyGoal) 个单词", value: $dailyGoal, in: 5...100, step: 5)
                    }
                    
                    Toggle("学习提醒", isOn: $studyReminder)
                    Toggle("推送通知", isOn: $enableNotifications)
                }
                
                Section("应用信息") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(version)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("ividernvi")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("其他") {
                    Button("清除学习记录") {
                        // 清除学习记录的动作
                    }
                    .foregroundColor(.red)
                    
                    Button("关于 EasyJp") {
                        // 显示关于页面的动作
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Item.self, inMemory: true)
}
