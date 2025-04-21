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
    
    // 확장된 색상 식별 함수
    static func identifyColorName(r: UInt8, g: UInt8, b: UInt8) -> String {
        // HSV 색상 공간으로 변환
        let (hue, saturation, value) = rgbToHsv(r: r, g: g, b: b)
        
        // 무채색 처리 (흰색, 회색, 검정색)
        if saturation < 0.1 {
            if value > 0.9 {
                return "White"
            } else if value < 0.1 {
                return "Black"
            } else if value < 0.3 {
                return "Dark Gray"
            } else if value < 0.7 {
                return "Gray"
            } else {
                return "Light Gray"
            }
        }
        
        // 채도가 낮은 색상 (파스텔)
        let isPastel = saturation < 0.4 && value > 0.7
        let pastelPrefix = isPastel ? "Light " : ""
        
        // 채도가 높고 명도가 낮은 색상 (어두운 색)
        let isDark = value < 0.5 && saturation > 0.4
        let darkPrefix = isDark ? "Dark " : ""
        
        // 주 색상 결정 (색상환 기반)
        let mainColor: String
        
        switch hue {
        case 0..<15, 345..<360:
            mainColor = "Red"
        case 15..<25:
            mainColor = "Vermilion"
        case 25..<40:
            mainColor = "Orange"
        case 40..<65:
            mainColor = "Yellow"
        case 65..<80:
            mainColor = "Lime"
        case 80..<163:
            mainColor = "Green"
        case 163..<193:
            mainColor = "Teal"
        case 193..<240:
            mainColor = "Blue"
        case 240..<260:
            mainColor = "Indigo"
        case 260..<280:
            mainColor = "Purple"
        case 280..<315:
            mainColor = "Magenta"
        case 315..<345:
            mainColor = "Pink"
        default:
            mainColor = "Unknown"
        }
        
        // 특수 색상 케이스 처리
        if mainColor == "Yellow" && saturation < 0.6 && value > 0.7 {
            return "Gold"
        } else if mainColor == "Orange" && value < 0.6 && saturation > 0.6 {
            return "Brown"
        } else if mainColor == "Red" && saturation > 0.7 && value < 0.6 {
            return "Maroon"
        } else if mainColor == "Yellow" && saturation < 0.5 && value < 0.8 {
            return "Olive"
        } else if mainColor == "Blue" && saturation > 0.5 && value < 0.4 {
            return "Navy"
        } else if mainColor == "Green" && saturation > 0.4 && value < 0.4 {
            return "Forest Green"
        }
        
        // 최종 색상 이름 결합
        return darkPrefix + pastelPrefix + mainColor
    }
    
    // 가장 가까운 색상 이름 찾기 (RGB 거리 기반)
    static func identifyColorNameFromNamedColors(r: UInt8, g: UInt8, b: UInt8) -> String {
        // 표준 색상 정의 (RGB 값과 이름)
        let namedColors: [(name: String, r: UInt8, g: UInt8, b: UInt8)] = [
            ("Red", 255, 0, 0),
            ("Dark Red", 139, 0, 0),
            ("Crimson", 220, 20, 60),
            ("Maroon", 128, 0, 0),
            ("Tomato", 255, 99, 71),
            ("Indian Red", 205, 92, 92),
            
            ("Orange", 255, 165, 0),
            ("Dark Orange", 255, 140, 0),
            ("Coral", 255, 127, 80),
            ("Gold", 255, 215, 0),
            
            ("Yellow", 255, 255, 0),
            ("Light Yellow", 255, 255, 224),
            ("Khaki", 240, 230, 140),
            
            ("Green", 0, 128, 0),
            ("Lime", 0, 255, 0),
            ("Lime Green", 50, 205, 50),
            ("Sea Green", 46, 139, 87),
            ("Forest Green", 34, 139, 34),
            ("Olive", 128, 128, 0),
            ("Spring Green", 0, 255, 127),
            ("Teal", 0, 128, 128),
            
            ("Cyan", 0, 255, 255),
            ("Light Cyan", 224, 255, 255),
            ("Turquoise", 64, 224, 208),
            
            ("Blue", 0, 0, 255),
            ("Dark Blue", 0, 0, 139),
            ("Navy", 0, 0, 128),
            ("Sky Blue", 135, 206, 235),
            ("Royal Blue", 65, 105, 225),
            ("Cornflower Blue", 100, 149, 237),
            ("Steel Blue", 70, 130, 180),
            
            ("Purple", 128, 0, 128),
            ("Indigo", 75, 0, 130),
            ("Violet", 238, 130, 238),
            ("Lavender", 230, 230, 250),
            ("Plum", 221, 160, 221),
            
            ("Magenta", 255, 0, 255),
            ("Fuchsia", 255, 0, 255),
            ("Hot Pink", 255, 105, 180),
            ("Pink", 255, 192, 203),
            ("Light Pink", 255, 182, 193),
            
            ("Brown", 165, 42, 42),
            ("Chocolate", 210, 105, 30),
            ("Sienna", 160, 82, 45),
            ("Peru", 205, 133, 63),
            ("Tan", 210, 180, 140),
            
            ("White", 255, 255, 255),
            ("Snow", 255, 250, 250),
            ("Ivory", 255, 255, 240),
            
            ("Gray", 128, 128, 128),
            ("Light Gray", 211, 211, 211),
            ("Dark Gray", 169, 169, 169),
            ("Silver", 192, 192, 192),
            
            ("Black", 0, 0, 0)
        ]
        
        // 입력 색상과 가장 가까운 색상 찾기
        var minDistance = Double.infinity
        var closestColorName = "Unknown"
        
        for namedColor in namedColors {
            // 유클리드 거리 계산 (3D 공간에서의 거리)
            let dr = Double(r) - Double(namedColor.r)
            let dg = Double(g) - Double(namedColor.g)
            let db = Double(b) - Double(namedColor.b)
            
            let distance = sqrt(dr*dr + dg*dg + db*db)
            
            if distance < minDistance {
                minDistance = distance
                closestColorName = namedColor.name
            }
        }
        
        return closestColorName
    }
    
    // 웹 색상 이름으로 식별
    static func identifyWebColorName(r: UInt8, g: UInt8, b: UInt8) -> String {
        // HSV 기반 색상 식별
        let basicColorName = identifyColorName(r: r, g: g, b: b)
        
        // 가장 가까운 표준 색상 이름 찾기
        let namedColorName = identifyColorNameFromNamedColors(r: r, g: g, b: b)
        
        // 두 방식의 조합
        return namedColorName
    }
}
