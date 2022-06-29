//
//  AnimationInfo.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 1/21/21.
//

import Foundation
import SceneKit

struct AnimationInfo {
    var startTime: TimeInterval
    var duration: TimeInterval
    var initialModelPosition: simd_float3
    var finalModelPosition: simd_float3
    var initialModelOrientation: simd_quatf
    var finalModelOrientation: simd_quatf
}
