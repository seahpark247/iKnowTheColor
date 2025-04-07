//
//  ContentView.swift
//  iKnowTheColor
//
//  Created by Seah Park on 4/3/25.
//

import SwiftUI
import AVFoundation

// 앱 처음실행때만 인트로 말해주고, 소리 꺼버리기.
// 설정 안에다가 목소리 스피드 설정하게 하기?
struct ContentView: View {
    @StateObject private var cameraModel = CameraModel()
    @StateObject private var speechService = SpeechService()
    
    // Create haptic feedback generator
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            // 카메라 프리뷰
            CameraPreview(session: cameraModel.session)
                .edgesIgnoringSafeArea(.all)
            
            // 중앙 타겟 마커
            Circle()
                .strokeBorder(Color(uiColor: cameraModel.detectedColor), lineWidth: 3)
                .frame(width: 70, height: 70)
                .background(Circle().fill(Color.black.opacity(0.1)))
            
            // 하단 정보 표시
            VStack {
                Spacer()
                
                Text(cameraModel.colorName ?? "Detecting color...")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            // Prepare haptic feedback generator
            impactFeedback.prepare()
            
            cameraModel.checkPermission()
            
            // 앱 시작 안내 음성
            speechService.speak("I know the color started. It will detect the color of objects in the center of the screen.")
        }
        .onChange(of: cameraModel.colorName) { newColorName in
            if let colorName = newColorName {
                speechService.announceColor(colorName)
            }
        }
        .onTapGesture {
            // 화면 탭하면 현재 색상 다시 알려주기
            // 햅틱 기능 추가
            impactFeedback.impactOccurred(intensity: 0.8)
            
            if let colorName = cameraModel.colorName, !colorName.isEmpty {
                speechService.speak("Current color is \(colorName).")
            } else {
                speechService.speak("No color detected yet.")
            }
        }
        .alert(isPresented: $cameraModel.showAlert) {
            Alert(
                title: Text(cameraModel.alertTitle),
                message: Text(cameraModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if cameraModel.alertTitle.contains("Permission") {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                }
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Color detection screen")
        .accessibilityHint("Tap the screen to hear the current color again.")
    }
}

// 미리보기 수정
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // 실제 카메라 기능이 없는 미리보기용 화면
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Circle()
                .strokeBorder(Color.red, lineWidth: 3)
                .frame(width: 70, height: 70)
                .background(Circle().fill(Color.black.opacity(0.1)))
            
            VStack {
                Spacer()
                Text("빨간색")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    ContentView()
}
