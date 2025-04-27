//
//  ColorDatasetGenerator.swift
//  iKnowTheColor
//
//  Created by Seah Park on 4/21/25.
//

import Foundation
import UIKit

class ColorDatasetGenerator {
    static func createColorImageDataset() {
        // CSV 파일 경로
        guard let csvPath = Bundle.main.path(forResource: "color_tones_dataset", ofType: "csv") else {
            print("CSV 파일을 찾을 수 없습니다.")
            return
        }
        
        // 학습 이미지를 저장할 디렉토리
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ColorImages")
        
        // 디렉토리 생성
        try? FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true)
        
        do {
            // CSV 파일 읽기
            let csvString = try String(contentsOfFile: csvPath, encoding: .utf8)
            let rows = csvString.components(separatedBy: "\n")
            
            // 헤더 제외
            for i in 1..<rows.count {
                let row = rows[i]
                if row.isEmpty { continue }
                
                // CSV 라인 파싱
                let columns = row.components(separatedBy: ",")
                if columns.count < 4 { continue }
                
                guard let r = UInt8(columns[0]),
                      let g = UInt8(columns[1]),
                      let b = UInt8(columns[2]) else {
                    continue
                }
                
                let label = columns[3]
                let folderName = label.replacingOccurrences(of: " ", with: "_")
                
                // 색상 별 폴더 생성
                let colorFolderPath = directoryPath.appendingPathComponent(folderName)
                try? FileManager.default.createDirectory(at: colorFolderPath, withIntermediateDirectories: true)
                
                // 다수의 샘플 이미지 생성 (변형을 주어 학습 효과 증대)
                for j in 1...10 {
                    // 약간의 변형을 주어 다양한 샘플 생성
                    let rVariation = max(0, min(255, Int(r) + Int.random(in: -10...10)))
                    let gVariation = max(0, min(255, Int(g) + Int.random(in: -10...10)))
                    let bVariation = max(0, min(255, Int(b) + Int.random(in: -10...10)))
                    
                    // 색상 이미지 생성
                    let size = CGSize(width: 224, height: 224) // 일반적인 ML 모델 입력 크기
                    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
                    
                    let color = UIColor(red: CGFloat(rVariation)/255.0,
                                       green: CGFloat(gVariation)/255.0,
                                        blue: CGFloat(bVariation)/255.0,
                                       alpha: 1.0)
                    color.setFill()
                    UIRectFill(CGRect(origin: .zero, size: size))
                    
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    // 이미지 저장
                    if let image = image, let data = image.pngData() {
                        let imagePath = colorFolderPath.appendingPathComponent("\(folderName)_\(j).png")
                        try data.write(to: imagePath)
                        print("이미지 저장: \(imagePath.path)")
                    }
                }
            }
            
            print("데이터셋 생성 완료: \(directoryPath.path)")
        } catch {
            print("오류 발생: \(error)")
        }
    }
}
