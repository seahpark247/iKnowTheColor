//
//  ContentView.swift
//  iKnowTheColor
//
//  Created by Seah Park on 4/3/25.
//

import SwiftUI
import AVFoundation

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
            speechService.speak("I know the color started. Tap anywhere on the screen to hear the color at the center.")
        }
        .onTapGesture {
            // 첫 번째 햅틱 피드백
            impactFeedback.impactOccurred(intensity: 1)
            
            // 두 번째 햅틱 피드백 (0.2초 후에 실행)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                impactFeedback.impactOccurred(intensity: 1)
            }
            
            if let colorName = cameraModel.colorName, !colorName.isEmpty {
                speechService.speak(colorName)
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
        .accessibilityHint("Tap the screen to hear the current color.")
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
