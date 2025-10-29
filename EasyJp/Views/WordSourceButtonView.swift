import SwiftUI
// 单词源按钮视图
struct WordSourceButtonView: View {
    let source: WordSource
    @State private var isExpanded = false
    
    var wordsByLevel: [String: [Word]] {
        Dictionary(grouping: source.words) { $0.level }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 单词源标题按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.blue)
                            Text(source.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Text(source.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        // 级别统计
                        HStack(spacing: 8) {
                            ForEach(wordsByLevel.keys.sorted(), id: \.self) { level in
                                Text("\(level): \(wordsByLevel[level]?.count ?? 0)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text("v\(source.version)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 展开的单词列表
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    ForEach(wordsByLevel.keys.sorted(), id: \.self) { level in
                        VStack(alignment: .leading, spacing: 8) {
                            // 级别标题
                            HStack {
                                Image(systemName: "flag.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Text(level)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("(\(wordsByLevel[level]?.count ?? 0) 个单词)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 4)
                            
                            // 该级别的单词
                            LazyVStack(spacing: 2) {
                                ForEach(wordsByLevel[level] ?? [], id: \.id) { word in
                                    WordRowView(word: word)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 2)
                                        .background(Color.white.opacity(0.5))
                                }
                            }
                            
                            if level != wordsByLevel.keys.sorted().last {
                                Divider()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    
                    // 底部间距
                    Color.clear
                        .frame(height: 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.08))
                        .padding(.horizontal, 8)
                )
                .transition(.opacity.combined(with: .slide))
            }
        }
    }
}

#Preview {
    NavigationView {
        List {
            WordSourceButtonView(source: WordSource(
                name: "测试词汇源", 
                description: "包含基础日语词汇的测试集合", 
                words: [
                    Word(word: "春", pronunciation: "[haru]", meaning: "春天", example: "春が来た。- 春天来了。", level: "N5", category: "季节"),
                    Word(word: "夏", pronunciation: "[natsu]", meaning: "夏天", example: "夏は暑いです。- 夏天很热。", level: "N5", category: "季节"),
                    Word(word: "勉強", pronunciation: "[benkyou]", meaning: "学习", example: "毎日勉強します。- 每天都学习。", level: "N4", category: "动作")
                ], 
                version: "1.0", 
                createdDate: Date()
            ))
        }
    }
}
