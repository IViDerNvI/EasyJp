
import SwiftUI

struct MainpageView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 背词页面
            StudyView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("背词")
                }
                .tag(0)
            
            // 单词表页面
            WordListView()
                .tabItem {
                    Image(systemName: "book")
                    Text("单词表")
                }
                .tag(1)
            
            // 设置页面
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("设置")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainpageView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(WordManager())
}
