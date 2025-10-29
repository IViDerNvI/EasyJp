//
//  WordModel.swift
//  EasyJp
//
//  Created by ividernvi on 2025/10/29.
//

import Foundation

// 单词数据模型
struct Word: Codable, Identifiable, Hashable {
    let id = UUID()
    let word: String
    let pronunciation: String
    let meaning: String
    let example: String
    let level: String // N5, N4, N3, N2, N1 等
    let category: String? // 可选分类
    
    private enum CodingKeys: String, CodingKey {
        case word, pronunciation, meaning, example, level, category
    }
}

// 单词源数据模型
struct WordSource: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let words: [Word]
    let version: String
    let createdDate: Date
    
    private enum CodingKeys: String, CodingKey {
        case name, description, words, version, createdDate
    }
}

// 单词管理器
class WordManager: ObservableObject {
    @Published var wordSources: [WordSource] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let documentsDirectory: URL
    private let wordSourcesFileName = "word_sources.json"
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadWordSources()
        loadDefaultWords()
    }
    
    // 加载本地保存的单词源
    private func loadWordSources() {
        let fileURL = documentsDirectory.appendingPathComponent(wordSourcesFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            wordSources = try decoder.decode([WordSource].self, from: data)
        } catch {
            errorMessage = "加载单词源失败: \(error.localizedDescription)"
        }
    }
    
    // 保存单词源到本地
    private func saveWordSources() {
        let fileURL = documentsDirectory.appendingPathComponent(wordSourcesFileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(wordSources)
            try data.write(to: fileURL)
        } catch {
            errorMessage = "保存单词源失败: \(error.localizedDescription)"
        }
    }
    
    // 加载默认单词
    private func loadDefaultWords() {
        if wordSources.isEmpty {
            let defaultWords = [
                Word(word: "学校", pronunciation: "がっこう", meaning: "学校", example: "学校に行きます。", level: "N5", category: "教育"),
                Word(word: "先生", pronunciation: "せんせい", meaning: "老师", example: "先生は親切です。", level: "N5", category: "人物"),
                Word(word: "学生", pronunciation: "がくせい", meaning: "学生", example: "私は学生です。", level: "N5", category: "人物"),
                Word(word: "勉強", pronunciation: "べんきょう", meaning: "学习", example: "毎日日本語を勉強しています。", level: "N4", category: "学习"),
                Word(word: "仕事", pronunciation: "しごと", meaning: "工作", example: "今日は仕事が忙しいです。", level: "N4", category: "工作"),
                Word(word: "友達", pronunciation: "ともだち", meaning: "朋友", example: "友達と一緒に映画を見ました。", level: "N4", category: "人际关系"),
                Word(word: "家族", pronunciation: "かぞく", meaning: "家族", example: "家族と一緒に住んでいます。", level: "N4", category: "家庭"),
                Word(word: "時間", pronunciation: "じかん", meaning: "时间", example: "時間がありません。", level: "N4", category: "时间"),
                Word(word: "今日", pronunciation: "きょう", meaning: "今天", example: "今日は天気がいいです。", level: "N5", category: "时间"),
                Word(word: "昨日", pronunciation: "きのう", meaning: "昨天", example: "昨日は雨でした。", level: "N5", category: "时间"),
                Word(word: "明日", pronunciation: "あした", meaning: "明天", example: "明日映画を見ます。", level: "N5", category: "时间"),
                Word(word: "日本", pronunciation: "にほん", meaning: "日本", example: "日本は美しい国です。", level: "N5", category: "国家"),
                Word(word: "日本語", pronunciation: "にほんご", meaning: "日语", example: "日本語を勉強しています。", level: "N5", category: "语言"),
                Word(word: "英語", pronunciation: "えいご", meaning: "英语", example: "英語も話せます。", level: "N5", category: "语言"),
                Word(word: "食事", pronunciation: "しょくじ", meaning: "用餐", example: "食事の時間です。", level: "N4", category: "饮食")
            ]
            
            let defaultSource = WordSource(
                name: "默认单词表",
                description: "内置的基础日语单词",
                words: defaultWords,
                version: "1.0",
                createdDate: Date()
            )
            
            wordSources.append(defaultSource)
            saveWordSources()
        }
    }
    
    // 从 JSON 文件导入单词源
    func importWordSource(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(priority: .background).async {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let wordSource = try decoder.decode(WordSource.self, from: data)
                
                DispatchQueue.main.async {
                    self.wordSources.append(wordSource)
                    self.saveWordSources()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "导入失败: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // 从网络 URL 导入单词源
    func importWordSource(from urlString: String) {
        guard let url = URL(string: urlString) else {
            errorMessage = "URL 格式无效"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 创建 URLSession 数据任务
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // 检查网络错误
                if let error = error {
                    self.errorMessage = "网络请求失败: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                // 检查 HTTP 响应状态
                if let httpResponse = response as? HTTPURLResponse {
                    guard httpResponse.statusCode == 200 else {
                        self.errorMessage = "服务器响应错误: HTTP \(httpResponse.statusCode)"
                        self.isLoading = false
                        return
                    }
                }
                
                // 检查数据
                guard let data = data else {
                    self.errorMessage = "未收到数据"
                    self.isLoading = false
                    return
                }
                
                // 解析 JSON 数据
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let wordSource = try decoder.decode(WordSource.self, from: data)
                    
                    // 检查是否已存在相同名称的单词源
                    if self.wordSources.contains(where: { $0.name == wordSource.name }) {
                        self.errorMessage = "已存在名为 '\(wordSource.name)' 的单词源"
                        self.isLoading = false
                        return
                    }
                    
                    self.wordSources.append(wordSource)
                    self.saveWordSources()
                    self.isLoading = false
                    
                } catch {
                    self.errorMessage = "JSON 解析失败: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
        
        task.resume()
    }
    
    // 导出单词源为 JSON
    func exportWordSource(_ source: WordSource) -> URL? {
        let fileName = "\(source.name)_\(Date().timeIntervalSince1970).json"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(source)
            try data.write(to: fileURL)
            return fileURL
        } catch {
            errorMessage = "导出失败: \(error.localizedDescription)"
            return nil
        }
    }
    
    // 删除单词源
    func deleteWordSource(_ source: WordSource) {
        wordSources.removeAll { $0.id == source.id }
        saveWordSources()
    }
    
    // 获取所有单词（按级别分组）
    func getAllWordsByLevel() -> [String: [Word]] {
        var wordsByLevel: [String: [Word]] = [:]
        
        for source in wordSources {
            for word in source.words {
                if wordsByLevel[word.level] == nil {
                    wordsByLevel[word.level] = []
                }
                wordsByLevel[word.level]?.append(word)
            }
        }
        
        return wordsByLevel
    }
    
    // 搜索单词
    func searchWords(query: String) -> [Word] {
        let allWords = wordSources.flatMap { $0.words }
        
        if query.isEmpty {
            return allWords
        }
        
        return allWords.filter { word in
            word.word.localizedCaseInsensitiveContains(query) ||
            word.meaning.localizedCaseInsensitiveContains(query) ||
            word.pronunciation.localizedCaseInsensitiveContains(query)
        }
    }
}
