//
//  WordView.swift
//  EasyJp
//
//  Created by ividernvi on 2025/10/29.
//

import SwiftUI

struct WordView: View {
    let word: String
    let pronunciation: String
    let meaning: String
    let example: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Word title
                Text(word)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Pronunciation
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.blue)
                    Text(pronunciation)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Meaning section
                VStack(alignment: .leading, spacing: 8) {
                    Text("意思")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(meaning)
                        .font(.body)
                        .padding(.horizontal)
                }
                
                Divider()
                
                // Example section
                VStack(alignment: .leading, spacing: 8) {
                    Text("例句")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(example)
                        .font(.body)
                        .italic()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    NavigationView {
        WordView(
            word: "こんにちは",
            pronunciation: "[konnichiwa]",
            meaning: "你好，日常问候语",
            example: "田中さん、こんにちは。- 田中先生，你好。"
        )
    }
}
