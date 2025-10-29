//
//  WordSourceViews.swift
//  EasyJp
//
//  Created by ividernvi on 2025/10/29.
//

import SwiftUI
import UniformTypeIdentifiers

// 导入单词源视图
struct ImportWordSourceView: View {
    @EnvironmentObject var wordManager: WordManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingFilePicker = false
    @State private var showingCreateForm = false
    @State private var showingURLImport = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("添加单词源")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("选择导入方式")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 15) {
                    Button(action: {
                        showingFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text("从 JSON 文件导入")
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingURLImport = true
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("从 URL 导入")
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingCreateForm = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("手动创建单词源")
                        }
                        .font(.title3)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("导入单词源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    wordManager.importWordSource(from: url)
                    if wordManager.errorMessage == nil {
                        dismiss()
                    }
                }
            case .failure(let error):
                wordManager.errorMessage = "文件选择失败: \(error.localizedDescription)"
            }
        }
        .sheet(isPresented: $showingCreateForm) {
            CreateWordSourceView()
                .environmentObject(wordManager)
        }
        .sheet(isPresented: $showingURLImport) {
            URLImportView()
                .environmentObject(wordManager)
        }
    }
}

// 创建单词源视图
struct CreateWordSourceView: View {
    @EnvironmentObject var wordManager: WordManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var words: [Word] = []
    @State private var showingAddWord = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("单词源名称", text: $name)
                    TextField("描述", text: $description, axis: .vertical)
                        .lineLimit(3)
                }
                
                Section("单词列表 (\(words.count) 个)") {
                    ForEach(words, id: \.id) { word in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(word.word)
                                .font(.headline)
                            Text("\(word.pronunciation) - \(word.meaning)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteWords)
                    
                    Button("添加单词") {
                        showingAddWord = true
                    }
                }
            }
            .navigationTitle("创建单词源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveWordSource()
                    }
                    .disabled(name.isEmpty || words.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingAddWord) {
            AddWordView { word in
                words.append(word)
            }
        }
    }
    
    private func deleteWords(offsets: IndexSet) {
        words.remove(atOffsets: offsets)
    }
    
    private func saveWordSource() {
        let wordSource = WordSource(
            name: name,
            description: description,
            words: words,
            version: "1.0",
            createdDate: Date()
        )
        
        wordManager.wordSources.append(wordSource)
        dismiss()
    }
}

// 添加单词视图
struct AddWordView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Word) -> Void
    
    @State private var word = ""
    @State private var pronunciation = ""
    @State private var meaning = ""
    @State private var example = ""
    @State private var level = "N5"
    @State private var category = ""
    
    let levels = ["N5", "N4", "N3", "N2", "N1"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("单词信息") {
                    TextField("日语单词", text: $word)
                    TextField("发音 (如: [konnichiwa])", text: $pronunciation)
                    TextField("中文意思", text: $meaning)
                }
                
                Section("详细信息") {
                    TextField("例句", text: $example, axis: .vertical)
                        .lineLimit(3)
                    
                    Picker("级别", selection: $level) {
                        ForEach(levels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    TextField("分类 (可选)", text: $category)
                }
            }
            .navigationTitle("添加单词")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let newWord = Word(
                            word: word,
                            pronunciation: pronunciation,
                            meaning: meaning,
                            example: example,
                            level: level,
                            category: category.isEmpty ? nil : category
                        )
                        onSave(newWord)
                        dismiss()
                    }
                    .disabled(word.isEmpty || pronunciation.isEmpty || meaning.isEmpty)
                }
            }
        }
    }
}

// 单词源管理视图
struct WordSourcesView: View {
    @EnvironmentObject var wordManager: WordManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportAlert = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(wordManager.wordSources, id: \.id) { source in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(source.name)
                                .font(.headline)
                            Spacer()
                            Text("\(source.words.count) 个单词")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(source.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("版本: \(source.version)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(source.createdDate, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button("导出") {
                            if let url = wordManager.exportWordSource(source) {
                                exportURL = url
                                showingExportAlert = true
                            }
                        }
                        .tint(.blue)
                        
                        Button("删除") {
                            wordManager.deleteWordSource(source)
                        }
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("单词源管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .alert("导出成功", isPresented: $showingExportAlert) {
            Button("确定") {
                exportURL = nil
            }
        } message: {
            if let url = exportURL {
                Text("文件已保存到: \(url.path)")
            }
        }
    }
}

// URL 导入视图
struct URLImportView: View {
    @EnvironmentObject var wordManager: WordManager
    @Environment(\.dismiss) private var dismiss
    @State private var urlString = ""
    @State private var showingExample = false
    
    // 示例 URL 列表
    private let exampleUrls = [
        "https://raw.githubusercontent.com/example/japanese-words/main/n5-basic.json",
        "https://api.example.com/wordlists/japanese-n4.json",
        "https://cdn.example.com/resources/jlpt-vocabulary.json"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题和图标
                VStack(spacing: 16) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("从 URL 导入")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("输入 JSON 文件的 URL 地址")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // URL 输入框
                VStack(alignment: .leading, spacing: 8) {
                    Text("JSON 文件 URL")
                        .font(.headline)
                    
                    TextField("https://example.com/wordlist.json", text: $urlString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // 示例 URL 按钮
                Button(action: {
                    showingExample.toggle()
                }) {
                    HStack {
                        Image(systemName: "lightbulb")
                        Text("查看示例 URL")
                    }
                    .foregroundColor(.blue)
                }
                
                if showingExample {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("示例 URL:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(exampleUrls, id: \.self) { url in
                            Button(action: {
                                urlString = url
                                showingExample = false
                            }) {
                                Text(url)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // 导入按钮
                Button(action: {
                    importFromURL()
                }) {
                    HStack {
                        if wordManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Text(wordManager.isLoading ? "导入中..." : "开始导入")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(urlString.isEmpty || wordManager.isLoading ? Color.gray : Color.green)
                    .cornerRadius(12)
                }
                .disabled(urlString.isEmpty || wordManager.isLoading)
                
                // 说明文本
                VStack(alignment: .leading, spacing: 8) {
                    Text("注意事项:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• URL 必须直接指向 JSON 文件")
                        Text("• 文件格式必须符合单词源规范")
                        Text("• 确保网络连接正常")
                        Text("• 大文件可能需要较长时间下载")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("URL 导入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .alert("错误", isPresented: .constant(wordManager.errorMessage != nil)) {
            Button("确定") {
                wordManager.errorMessage = nil
            }
        } message: {
            Text(wordManager.errorMessage ?? "")
        }
        .onChange(of: wordManager.isLoading) { _, isLoading in
            if !isLoading && wordManager.errorMessage == nil {
                // 导入成功，关闭弹窗
                dismiss()
            }
        }
    }
    
    private func importFromURL() {
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        wordManager.importWordSource(from: trimmedURL)
    }
}