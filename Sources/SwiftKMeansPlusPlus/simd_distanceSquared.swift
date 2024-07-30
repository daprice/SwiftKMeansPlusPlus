//
//  simd_distanceSquared.swift
//
//
//  Created by Dale Price on 7/30/24.
//

import Foundation
import simd

/// Calculate the squared euclidean distance between any two SIMD "points".
internal func distanceSquared<P: SIMD>(_ lhs: P, _ rhs: P) -> P.Scalar where P.Scalar: FloatingPoint {
	let diff = rhs - lhs
	let diffSquared = diff * diff
	return diffSquared.sum()
}
