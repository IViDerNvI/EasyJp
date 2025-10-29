//
//  StudySessionView.swift
//  EasyJp
//
//  Created by ividernvi on 2025/10/29.
//

import SwiftUI

// 背词练习界面
struct StudySessionView: View {
    @EnvironmentObject var wordManager: WordManager
    let wordSource: WordSource
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentWordIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var selectedAnswer: String? = nil
    @State private var showCorrectAnswer = false
    @State private var studiedWords: Set<UUID> = []
    @State private var options: [String] = []
    
    // 获取当前单词
    private var currentWord: Word {
        wordSource.words[currentWordIndex]
    }
    
    // 判断是否是最后一个单词
    private var isLastWord: Bool {
        currentWordIndex >= wordSource.words.count - 1
    }
    
    // 进度百分比
    private var progress: Double {
        Double(currentWordIndex) / Double(wordSource.words.count)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 进度条
                VStack(spacing: 10) {
                    HStack {
                        Text("进度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(currentWordIndex + 1) / \(wordSource.words.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // 问题区域
                        VStack(spacing: 15) {
                            Text("选择正确的读音")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // 汉字单词
                            Text(currentWord.word)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.blue.opacity(0.1))
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                )
                            
                            // 中文意思
                            Text(currentWord.meaning)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // 选项区域
                        VStack(spacing: 15) {
                            ForEach(options, id: \.self) { option in
                                OptionButton(
                                    text: option,
                                    isSelected: selectedAnswer == option,
                                    isCorrect: showCorrectAnswer ? (option == currentWord.pronunciation) : nil,
                                    action: {
                                        if selectedAnswer == nil {
                                            selectAnswer(option)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // 下一题按钮
                        if showCorrectAnswer {
                            Button(action: nextWord) {
                                Text(isLastWord ? "完成练习" : "下一题")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("背词练习")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("退出") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("得分: \(score)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
            }
        }
        .onAppear {
            setupOptions()
        }
        .sheet(isPresented: $showResult) {
            StudyResultView(
                score: score,
                totalWords: wordSource.words.count,
                studiedWords: studiedWords.count,
                onRestart: restartStudy,
                onExit: { dismiss() }
            )
        }
    }
    
    // 设置选项
    private func setupOptions() {
        var optionSet: Set<String> = []
        optionSet.insert(currentWord.pronunciation)
        
        // 从其他单词中随机选择错误选项
        let otherWords = wordSource.words.filter { $0.id != currentWord.id }
        let shuffledOthers = otherWords.shuffled()
        
        for word in shuffledOthers {
            if optionSet.count >= 4 { break }
            optionSet.insert(word.pronunciation)
        }
        
        // 如果选项不够4个，从常见读音中添加
        let commonReadings = [
            "こんにちは", "ありがとう", "すみません", "おはよう",
            "さようなら", "はじめまして", "よろしく", "げんき",
            "べんきょう", "しごと", "ともだち", "がっこう",
            "せんせい", "がくせい", "にほんご", "えいご"
        ]
        
        for reading in commonReadings.shuffled() {
            if optionSet.count >= 4 { break }
            if !optionSet.contains(reading) {
                optionSet.insert(reading)
            }
        }
        
        options = Array(optionSet).shuffled()
    }
    
    // 选择答案
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        
        if answer == currentWord.pronunciation {
            score += 1
            studiedWords.insert(currentWord.id)
        }
        
        showCorrectAnswer = true
    }
    
    // 下一题
    private func nextWord() {
        if isLastWord {
            showResult = true
            return
        }
        
        currentWordIndex += 1
        selectedAnswer = nil
        showCorrectAnswer = false
        setupOptions()
    }
    
    // 重新开始
    private func restartStudy() {
        currentWordIndex = 0
        score = 0
        selectedAnswer = nil
        showCorrectAnswer = false
        studiedWords.removeAll()
        setupOptions()
        showResult = false
    }
}

// 选项按钮组件
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            if isCorrect {
                return .green
            } else if isSelected {
                return .red
            } else {
                return Color.gray.opacity(0.2)
            }
        } else if isSelected {
            return .blue
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        if isCorrect == true || (isCorrect == false && isSelected) {
            return .white
        } else if isSelected {
            return .white
        } else {
            return .primary
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                
                Spacer()
                
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? (isCorrect == true ? Color.green : Color.blue) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .disabled(isCorrect != nil)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.3), value: isCorrect)
    }
}

// 练习结果界面
struct StudyResultView: View {
    let score: Int
    let totalWords: Int
    let studiedWords: Int
    let onRestart: () -> Void
    let onExit: () -> Void
    
    private var accuracy: Double {
        totalWords > 0 ? Double(score) / Double(totalWords) : 0
    }
    
    private var grade: String {
        switch accuracy {
        case 0.9...:
            return "优秀"
        case 0.8..<0.9:
            return "良好"
        case 0.6..<0.8:
            return "及格"
        default:
            return "需要努力"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 成绩显示
                VStack(spacing: 20) {
                    Text("练习完成!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(grade)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    // 统计信息
                    VStack(spacing: 15) {
                        HStack {
                            Text("正确率")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(accuracy * 100))%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("答对题目")
                                .font(.headline)
                            Spacer()
                            Text("\(score) / \(totalWords)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("学习单词")
                                .font(.headline)
                            Spacer()
                            Text("\(studiedWords)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                
                Spacer()
                
                // 按钮区域
                VStack(spacing: 15) {
                    Button(action: onRestart) {
                        Text("再练一次")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    
                    Button(action: onExit) {
                        Text("返回首页")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("练习结果")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let sampleWords = [
        Word(word: "こんにちは", pronunciation: "[konnichiwa]", meaning: "你好", example: "田中さん、こんにちは。", level: "N5", category: "问候"),
        Word(word: "ありがとう", pronunciation: "[arigatou]", meaning: "谢谢", example: "手伝ってくれて、ありがとう。", level: "N5", category: "问候"),
        Word(word: "すみません", pronunciation: "[sumimasen]", meaning: "对不起", example: "遅れてすみません。", level: "N5", category: "道歉")
    ]
    
    let sampleSource = WordSource(
        name: "预览单词源",
        description: "用于预览的示例单词",
        words: sampleWords,
        version: "1.0",
        createdDate: Date()
    )
    
    StudySessionView(wordSource: sampleSource)
        .environmentObject(WordManager())
}