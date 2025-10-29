import SwiftUI

// 单词行视图
struct WordRowView: View {
    let word: Word
    
    var body: some View {
        NavigationLink(destination: WordView(
            word: word.word,
            pronunciation: word.pronunciation,
            meaning: word.meaning,
            example: word.example
        )) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.word)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(word.pronunciation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(word.meaning)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                    
                    if let category = word.category {
                        Text(category)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        List {
            WordRowView(word: Word(
                word: "春", 
                pronunciation: "[haru]", 
                meaning: "春天", 
                example: "春が来た。- 春天来了。", 
                level: "N5", 
                category: "季节"
            ))
        }
    }
}
