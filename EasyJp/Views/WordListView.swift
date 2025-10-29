
import SwiftUI

// 单词表页面
struct WordListView: View {
    @EnvironmentObject var wordManager: WordManager
    @State private var searchText = ""
    @State private var showingImportSheet = false
    @State private var showingWordSources = false
    
    var filteredWords: [Word] {
        if searchText.isEmpty {
            return wordManager.wordSources.flatMap { $0.words }
        } else {
            return wordManager.searchWords(query: searchText)
        }
    }
    
    var wordsByLevel: [String: [Word]] {
        Dictionary(grouping: filteredWords) { $0.level }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if wordManager.isLoading {
                    ProgressView("加载中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // 单词源管理按钮
                        Section {
                            Button(action: {
                                showingWordSources = true
                            }) {
                                HStack {
                                    Image(systemName: "folder.badge.gearshape")
                                        .foregroundColor(.blue)
                                    Text("管理单词源")
                                    Spacer()
                                    Text("\(wordManager.wordSources.count) 个源")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        
                    }
                    .searchable(text: $searchText, prompt: "搜索单词、发音或意思")
                }
            }
            .navigationTitle("单词表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportWordSourceView()
                    .environmentObject(wordManager)
            }
            .sheet(isPresented: $showingWordSources) {
                WordSourcesView()
                    .environmentObject(wordManager)
            }
            .alert("错误", isPresented: .constant(wordManager.errorMessage != nil)) {
                Button("确定") {
                    wordManager.errorMessage = nil
                }
            } message: {
                Text(wordManager.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    WordListView()
        .environmentObject(WordManager())
}
