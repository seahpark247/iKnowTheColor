//
//  SpeechService.swift
//  iKnowTheColor
//
//  Created by Seah Park on 4/7/25.
//

import Foundation
import AVFoundation

class SpeechService: NSObject, ObservableObject {
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var lastSpokenColor: String?
    private var lastSpokenTime: Date?
    private let cooldownTime: TimeInterval = 2.0 // 같은 색상 반복 발화 사이의 시간 간격
    
    override init() {
        super.init()
    }
    
    // 음성 안내 함수
    func announceColor(_ colorName: String) {
        let now = Date()
        
        // 같은 색상을 반복해서 말하지 않도록 제한
        if colorName == lastSpokenColor,
           let lastTime = lastSpokenTime,
           now.timeIntervalSince(lastTime) < cooldownTime {
            return
        }
        
        speak(colorName)
        lastSpokenColor = colorName
        lastSpokenTime = now
    }
    
    // TTS 함수
    func speak(_ text: String) {
        // 이미 말하고 있는 경우 중단
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        // 새 음성 합성
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
}
