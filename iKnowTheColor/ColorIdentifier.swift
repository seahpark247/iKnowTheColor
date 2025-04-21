//
//  ColorIdentifier.swift
//  iKnowTheColor
//
//  Created by Seah Park on 4/7/25.
//

import Foundation
import UIKit

struct ColorIdentifier {
    
    // RGB 값을 HSV(HSB) 값으로 변환
    private static func rgbToHsv(r: UInt8, g: UInt8, b: UInt8) -> (h: Double, s: Double, v: Double) {
        let red = Double(r) / 255.0
        let green = Double(g) / 255.0
        let blue = Double(b) / 255.0
        
        let maxValue = max(red, green, blue)
        let minValue = min(red, green, blue)
        let delta = maxValue - minValue
        
        // 명도(Value)
        let value = maxValue
        
        // 채도(Saturation)
        let saturation = maxValue == 0 ? 0 : delta / maxValue
        
        // 색상(Hue)
        var hue: Double = 0
        
        if delta == 0 {
            hue = 0 // 무채색 (회색, 흰색, 검정색)
        } else if maxValue == red {
            hue = 60 * (((green - blue) / delta).truncatingRemainder(dividingBy: 6))
        } else if maxValue == green {
            hue = 60 * (((blue - red) / delta) + 2)
        } else { // maxValue == blue
            hue = 60 * (((red - green) / delta) + 4)
        }
        
        if hue < 0 {
            hue += 360
        }
        
        return (hue, saturation, value)
    }
    
    // 11가지 기본 색상 분류
    private static func determineBaseColor(h: Double, s: Double, v: Double) -> String {
        // 무채색 처리 (흰색, 회색, 검정색)
        if s < 0.1 {
            if v > 0.9 {
                return "White"
            } else if v < 0.15 {
                return "Black"
            } else {
                return "Gray"
            }
        }
        
        // 유채색 분류 (색상환 기반)
        switch h {
        case 0..<15, 345..<360:
            return "Red"
        case 15..<45:
            return "Orange"
        case 45..<65:
            return "Yellow"
        case 65..<170:
            return "Green"
        case 170..<260:
            return "Blue"
        case 260..<290:
            return "Purple"
        case 290..<345:
            // 어두운 핑크는 퍼플에 가깝고, 밝은 핑크는 레드에 가까움
            if s < 0.4 && v > 0.8 {
                return "Pink"
            } else if v > 0.7 {
                return "Pink"
            } else {
                return "Purple"
            }
        default:
            // 갈색은 채도와 명도로 판단
            if (h >= 15 && h < 45) && s > 0.2 && v < 0.6 {
                return "Brown"
            }
            return "Unknown"
        }
    }
    
    // 7가지 톤 분류
    private static func determineTone(s: Double, v: Double) -> String {
        if v < 0.2 {
            return "Very Dark"
        } else if v < 0.4 {
            return "Dark"
        } else if v < 0.6 {
            if s > 0.7 {
                return "Deep"
            } else {
                return "Dark"
            }
        } else if v < 0.8 {
            if s > 0.7 {
                return "Bright"
            } else {
                return "Medium"
            }
        } else if v < 0.9 {
            if s > 0.3 {
                return "Light"
            } else {
                return "Very Light"
            }
        } else {
            return "Very Light"
        }
    }
    
    // 특별한 케이스 처리 (갈색)
    private static func handleSpecialCases(baseColor: String, h: Double, s: Double, v: Double) -> String {
        // 갈색 케이스
        if (h >= 0 && h < 50) && s > 0.2 && v < 0.7 && v > 0.2 {
            if v < 0.3 {
                return "Very Dark Brown"
            } else if v < 0.4 {
                return "Dark Brown"
            } else if v < 0.5 {
                return "Deep Brown"
            } else if v < 0.6 {
                return "Medium Brown"
            } else {
                return "Light Brown"
            }
        }
        
        return baseColor
    }
    
    // 색상 식별 메인 함수
    static func identifyColorName(r: UInt8, g: UInt8, b: UInt8) -> String {
        // HSV 색상 공간으로 변환
        let (hue, saturation, value) = rgbToHsv(r: r, g: g, b: b)
        
        // 기본 색상 결정
        var baseColor = determineBaseColor(h: hue, s: saturation, v: value)
        
        // 특별한 케이스 처리
        let specialCase = handleSpecialCases(baseColor: baseColor, h: hue, s: saturation, v: value)
        if specialCase != baseColor {
            return specialCase
        }
        
        // 톤 결정
        let tone = determineTone(s: saturation, v: value)
        
        // 최종 색상 이름 (톤 + 색상)
        return "\(tone) \(baseColor)"
    }
    
    // 11개 색상과 7개 톤으로 정확히 분류하는 함수
    static func identifyStandardColorTone(r: UInt8, g: UInt8, b: UInt8) -> String {
        // 표준 색상 정의 (CSV 파일 내용 기반)
        let standardColors: [(tone: String, color: String, r: UInt8, g: UInt8, b: UInt8)] = [
            // Red
            ("Very Light", "Red", 255, 204, 204),
            ("Light", "Red", 255, 153, 153),
            ("Medium", "Red", 255, 102, 102),
            ("Bright", "Red", 255, 0, 0),
            ("Deep", "Red", 204, 0, 0),
            ("Dark", "Red", 153, 0, 0),
            ("Very Dark", "Red", 102, 0, 0),
            
            // Orange
            ("Very Light", "Orange", 255, 229, 204),
            ("Light", "Orange", 255, 204, 153),
            ("Medium", "Orange", 255, 178, 102),
            ("Bright", "Orange", 255, 128, 0),
            ("Deep", "Orange", 230, 115, 0),
            ("Dark", "Orange", 204, 85, 0),
            ("Very Dark", "Orange", 153, 63, 0),
            
            // Yellow
            ("Very Light", "Yellow", 255, 255, 204),
            ("Light", "Yellow", 255, 255, 153),
            ("Medium", "Yellow", 255, 255, 102),
            ("Bright", "Yellow", 255, 255, 0),
            ("Deep", "Yellow", 230, 230, 0),
            ("Dark", "Yellow", 204, 204, 0),
            ("Very Dark", "Yellow", 153, 153, 0),
            
            // Green
            ("Very Light", "Green", 229, 255, 204),
            ("Light", "Green", 204, 255, 153),
            ("Medium", "Green", 153, 255, 102),
            ("Bright", "Green", 0, 255, 0),
            ("Deep", "Green", 0, 204, 0),
            ("Dark", "Green", 0, 153, 0),
            ("Very Dark", "Green", 0, 102, 0),
            
            // Blue
            ("Very Light", "Blue", 204, 229, 255),
            ("Light", "Blue", 153, 204, 255),
            ("Medium", "Blue", 102, 178, 255),
            ("Bright", "Blue", 0, 128, 255),
            ("Deep", "Blue", 0, 102, 204),
            ("Dark", "Blue", 0, 76, 153),
            ("Very Dark", "Blue", 0, 51, 102),
            
            // Purple
            ("Very Light", "Purple", 242, 204, 255),
            ("Light", "Purple", 229, 153, 255),
            ("Medium", "Purple", 216, 102, 255),
            ("Bright", "Purple", 178, 0, 255),
            ("Deep", "Purple", 127, 0, 178),
            ("Dark", "Purple", 102, 0, 153),
            ("Very Dark", "Purple", 76, 0, 115),
            
            // Pink
            ("Very Light", "Pink", 255, 204, 229),
            ("Light", "Pink", 255, 153, 204),
            ("Medium", "Pink", 255, 102, 178),
            ("Bright", "Pink", 255, 51, 153),
            ("Deep", "Pink", 204, 0, 102),
            ("Dark", "Pink", 153, 0, 76),
            ("Very Dark", "Pink", 102, 0, 51),
            
            // Brown
            ("Very Light", "Brown", 242, 229, 204),
            ("Light", "Brown", 217, 179, 130),
            ("Medium", "Brown", 160, 120, 90),
            ("Bright", "Brown", 139, 90, 43),
            ("Deep", "Brown", 101, 67, 33),
            ("Dark", "Brown", 80, 50, 20),
            ("Very Dark", "Brown", 65, 40, 15),
            
            // Gray
            ("Very Light", "Gray", 242, 242, 242),
            ("Light", "Gray", 217, 217, 217),
            ("Medium", "Gray", 166, 166, 166),
            ("Bright", "Gray", 128, 128, 128),
            ("Deep", "Gray", 89, 89, 89),
            ("Dark", "Gray", 64, 64, 64),
            ("Very Dark", "Gray", 38, 38, 38),
            
            // White
            ("Very Light", "White", 255, 255, 255),
            ("Light", "White", 242, 242, 242),
            ("Medium", "White", 230, 230, 230),
            ("Bright", "White", 217, 217, 217),
            ("Deep", "White", 204, 204, 204),
            ("Dark", "White", 191, 191, 191),
            ("Very Dark", "White", 179, 179, 179),
            
            // Black
            ("Very Light", "Black", 64, 64, 64),
            ("Light", "Black", 51, 51, 51),
            ("Medium", "Black", 38, 38, 38),
            ("Bright", "Black", 26, 26, 26),
            ("Deep", "Black", 13, 13, 13),
            ("Dark", "Black", 5, 5, 5),
            ("Very Dark", "Black", 0, 0, 0)
        ]
        
        // 유클리드 거리로 가장 가까운 표준 색상 찾기
        var minDistance = Double.infinity
        var closestColor = "Unknown"
        
        for standardColor in standardColors {
            let dr = Double(r) - Double(standardColor.r)
            let dg = Double(g) - Double(standardColor.g)
            let db = Double(b) - Double(standardColor.b)
            
            let distance = sqrt(dr*dr + dg*dg + db*db)
            
            if distance < minDistance {
                minDistance = distance
                closestColor = "\(standardColor.tone) \(standardColor.color)"
            }
        }
        
        return closestColor
    }
}
