/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Shared layout constants for consistent spacing and materials across windows.
*/

import SwiftUI

enum ReSoundLayout {
    /// Vertical space between major sections (replaces ad hoc `Spacer().frame(height:)`).
    static let sectionSpacing: CGFloat = 24
    /// Default spacing inside stacks of controls.
    static let stackSpacing: CGFloat = 16
    /// Padding inside glass cards.
    static let cardPadding: CGFloat = 20
    /// Corner radius for glass panels and grouped controls.
    static let cardCornerRadius: CGFloat = 25
    /// Outer vertical padding for root menu content.
    static let outerVerticalPadding: CGFloat = 24
}
