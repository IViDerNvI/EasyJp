//
//  TestView.swift
//  EasyJp
//
//  Created by ividernvi on 2025/10/29.
//

import SwiftUI

// 测试视图，用于验证 WordManager 和相关组件是否正常工作
struct TestView: View {
    @StateObject private var wordManager = WordManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("单词源数量: \(wordManager.wordSources.count)")
                    .font(.headline)
                
                if !wordManager.wordSources.isEmpty {
                    Text("总单词数: \(wordManager.wordSources.flatMap { $0.words }.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                List {
                    ForEach(wordManager.wordSources, id: \.id) { source in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(source.name)
                                .font(.headline)
                            Text(source.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(source.words.count) 个单词")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("EasyJp 测试")
        }
    }
}

#Preview {
    TestView()
}