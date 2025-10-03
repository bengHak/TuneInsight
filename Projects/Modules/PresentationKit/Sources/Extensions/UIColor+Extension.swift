//
//  UIColor+Extension.swift
//  PresentationKit
//
//  Created by Byunghak on 10/3/25.
//  Copyright © 2025 Sparkish. All rights reserved.
//

import UIKit

enum CustomColor {
    // MARK: - Core Palette
    static let spotifyGreen = UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1.0)
    static let background = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    static let surface = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1.0)
    static let surfaceElevated = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1.0)
    static let surfaceMuted = UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1.0)
    static let accent = spotifyGreen
    static let accentMuted = UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 0.22)

    // MARK: - Typography
    static let primaryText = UIColor(white: 1.0, alpha: 0.95)
    static let secondaryText = UIColor(white: 1.0, alpha: 0.72)
    static let tertiaryText = UIColor(white: 1.0, alpha: 0.56)

    // MARK: - Utility
    static let separator = UIColor(white: 1.0, alpha: 0.12)
    static let border = UIColor(white: 1.0, alpha: 0.08)
    static let overlay = UIColor(white: 1.0, alpha: 0.05)
    static let clear = UIColor.clear

    // MARK: - Legacy Compatibility
    static let label = primaryText
    static let white = UIColor.white
    static let black = UIColor.black
}
