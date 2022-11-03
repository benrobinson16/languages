import SwiftUI
import UIKit

struct ShakeEffect: GeometryEffect {
    let shakesPerAnimation = 4.0
    let shakeAmplitude = 10.0
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let proportion = sin(.pi * shakesPerAnimation * animatableData)
        return ProjectionTransform(.init(
            translationX: proportion * shakeAmplitude,
            y: 0
        ))
    }
}

struct RotationShakeEffect: GeometryEffect {
    let shakesPerAnimation = 4.0
    let shakeAmplitudeX = 5.0
    let shakeAmplitudeY = 5.0
    let shakeRotation = 1.0
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let proportion = sin(.pi * shakesPerAnimation * animatableData)
        let transform = CGAffineTransform(1.0, 1.0, 1.0, proportion * shakeRotation, proportion * shakeAmplitudeX, proportion * shakeAmplitudeY)
        return ProjectionTransform(transform)
    }
}
