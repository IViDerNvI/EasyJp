import SwiftUI
// 背词页面
struct StudyView: View {
    @EnvironmentObject var wordManager: WordManager
    @State private var selectedWordSource: WordSource?
    @State private var showingWordSourcePicker = false
    @State private var showingStudySession = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 标题
                Text("开始学习日语")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // 单词源选择卡片
                VStack(spacing: 12) {
                    HStack {
                        Text("选择单词源")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    Button(action: {
                        showingWordSourcePicker = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedWordSource?.name ?? "请选择单词源")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedWordSource != nil ? .primary : .secondary)
                                
                                if let source = selectedWordSource {
                                    Text("\(source.words.count) 个单词")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
                
                // 学习进度卡片
                if let selectedSource = selectedWordSource {
                    VStack(spacing: 15) {
                        HStack {
                            Text("学习统计")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        HStack {
                            VStack {
                                Text("0")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("已学习")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("\(selectedSource.words.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("总计")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("0")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("待复习")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // 进度条
                        ProgressView(value: 0.0, total: Double(selectedSource.words.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                
                // 开始学习按钮
                Button(action: {
                    showingStudySession = true
                }) {
                    Text("开始背词")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedWordSource != nil ? Color.blue : Color.gray)
                        .cornerRadius(15)
                }
                .disabled(selectedWordSource == nil)
                
                // 复习按钮
                Button(action: {
                    // 开始复习的动作
                    // TODO: 导航到复习界面，传入选中的单词源
                }) {
                    Text("复习单词")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedWordSource != nil ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((selectedWordSource != nil ? Color.blue : Color.gray).opacity(0.1))
                        .cornerRadius(15)
                }
                .disabled(selectedWordSource == nil)
                
                Spacer()
            }
            .padding()
            .navigationTitle("EasyJp")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingWordSourcePicker) {
                WordSourcePickerView(selectedWordSource: $selectedWordSource)
                    .environmentObject(wordManager)
            }
            .fullScreenCover(isPresented: $showingStudySession) {
                if let selectedSource = selectedWordSource {
                    StudySessionView(wordSource: selectedSource)
                        .environmentObject(wordManager)
                }
            }
            .onAppear {
                // 如果没有选择单词源，默认选择第一个
                if selectedWordSource == nil && !wordManager.wordSources.isEmpty {
                    selectedWordSource = wordManager.wordSources.first
                }
            }
        }
    }
}

// 单词源选择器视图
struct WordSourcePickerView: View {
    @EnvironmentObject var wordManager: WordManager
    @Binding var selectedWordSource: WordSource?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(wordManager.wordSources) { source in
                    Button(action: {
                        selectedWordSource = source
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(source.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(source.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                HStack {
                                    Text("\(source.words.count) 个单词")
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                    
                                    Text("v\(source.version)")
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.1))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedWordSource?.id == source.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("选择单词源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("管理") {
                        dismiss()
                        // TODO: 打开单词源管理界面
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    StudyView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(WordManager())
}
