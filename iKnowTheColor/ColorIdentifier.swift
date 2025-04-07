//
//  ColorIdentifier.swift
//  iKnowTheColor
//
//  Created by Seah Park on 4/7/25.
//

import Foundation

struct ColorIdentifier {
    static func identifyColorName(r: UInt8, g: UInt8, b: UInt8) -> String {
        // 기본 색상 정의
        let colorMapping: [(name: String, condition: (UInt8, UInt8, UInt8) -> Bool)] = [
            ("Red", { r, g, b in r > 200 && g < 100 && b < 100 }),
            ("Orange", { r, g, b in r > 200 && g > 100 && g < 200 && b < 100 }),
            ("Yellow", { r, g, b in r > 200 && g > 200 && b < 100 }),
            ("Green", { r, g, b in r < 100 && g > 150 && b < 100 }),
            ("Cyan", { r, g, b in r < 100 && g > 150 && b > 150 }),
            ("Blue", { r, g, b in r < 100 && g < 100 && b > 150 }),
            ("Purple", { r, g, b in r > 100 && r < 200 && g < 100 && b > 150 }),
            ("Pink", { r, g, b in r > 200 && g < 150 && b > 150 }),
            ("Brown", { r, g, b in r > 100 && r < 200 && g > 50 && g < 150 && b < 100 }),
            ("White", { r, g, b in r > 200 && g > 200 && b > 200 }),
            ("Gray", { r, g, b in r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200 }),
            ("Black", { r, g, b in r < 50 && g < 50 && b < 50 })
        ]
        
        // 색상 이름 찾기
        for (name, condition) in colorMapping {
            if condition(r, g, b) {
                return name
            }
        }
        
        // 기본값
        return "Unknown color"
    }
}
