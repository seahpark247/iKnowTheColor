//
//  CameraModel.swift
//  iKnowTheColor
//
//  Created by Seah Park on 4/7/25.
//

import SwiftUI
import AVFoundation

class CameraModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var colorName: String? = nil
    @Published var detectedColor: UIColor = .white
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    override init() {
        super.init()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                } else {
                    self?.handlePermissionDenied()
                }
            }
        case .denied, .restricted:
            handlePermissionDenied()
        @unknown default:
            break
        }
    }
    
    private func handlePermissionDenied() {
        DispatchQueue.main.async { [weak self] in
            self?.alertTitle = "Camera Permission Required"
            self?.alertMessage = "This app needs camera access. Please enable camera access in Settings."
            self?.showAlert = true
        }
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            // 입력 설정
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.session.canAddInput(videoInput) else {
                self.showCameraError()
                return
            }
            
            self.session.addInput(videoInput)
            
            // 출력 설정
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    private func showCameraError() {
        DispatchQueue.main.async { [weak self] in
            self?.alertTitle = "Camera Error"
            self?.alertMessage = "Cannot access the camera."
            self?.showAlert = true
        }
    }
    
    // 비디오 프레임 처리
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // 중앙 픽셀 좌표 계산
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let centerX = width / 2
        let centerY = height / 2
        
        // 픽셀 버퍼 락
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        // 중앙 픽셀의 색상 추출
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            return
        }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let pixelAddress = baseAddress + centerY * bytesPerRow + centerX * 4
        
        // BGRA 포맷에서 색상 값 추출
        let b = pixelAddress.load(as: UInt8.self)
        let g = pixelAddress.load(fromByteOffset: 1, as: UInt8.self)
        let r = pixelAddress.load(fromByteOffset: 2, as: UInt8.self)
        let a = pixelAddress.load(fromByteOffset: 3, as: UInt8.self)
        
        // 픽셀 버퍼 언락
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        // 색상 이름 결정 및 UI 업데이트
        let newColor = UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
        let newColorName = ColorIdentifier.identifyColorName(r: r, g: g, b: b)
        
        DispatchQueue.main.async { [weak self] in
            self?.detectedColor = newColor
            self?.colorName = newColorName
        }
    }
}
