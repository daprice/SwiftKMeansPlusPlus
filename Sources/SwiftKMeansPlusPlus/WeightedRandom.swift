//
//  WeightedRandom.swift
//
//
//  Created by Dale Price on 7/30/24.
//

import Foundation
import OrderedCollections

public extension Int {
	// Inspired by https://stackoverflow.com/a/30309951/6833424
	/// Generate a random integer between 0 and `weights.count`, using the values in `weights` as relative probabilities, using the given generator as a source for randomness.
	///
	/// ### Examples
	///
	/// The following code has a 25% chance of returning `0` and a 75% chance of returning `1`:
	/// ```swift
	///random([0.25, 0.75])
	/// ```
	///
	/// The weight values don't have to add up to `1`. For example, the following code has a 25% chance of returning `0`, a 25% chance of returning `1`, and a 50% chance of returning `2`:
	/// ```swift
	///random([1, 1, 2])
	/// ```
	///
	/// - Parameters:
	///   - weights: Collection of weight values representing the relative chance of each value's index being randomly chosen.
	///   - generator: RandomNumberGenerator instance to use.
	/// - Returns: `Int` in the range of `0..<weights.count`, randomly chosen using the given weights.
	static func random<W: RandomAccessCollection, R: RandomNumberGenerator>(weights: W, using generator: inout R) -> Int where W.Index == Int, W.Element: BinaryFloatingPoint, W.Element.RawSignificand: FixedWidthInteger {
		guard !weights.isEmpty else {
			return weights.startIndex
		}
		
		let sum = weights.reduce(0, +)
		let random = W.Element.random(in: 0 ..< sum, using: &generator)
		
		var accumulated: W.Element = 0.0
		for (index, weight) in weights.enumerated() {
			accumulated += weight
			if random < accumulated {
				return index
			}
		}
		
		return weights.endIndex - 1
	}
	
	/// Generate a random integer between 0 and `weights.count`, using the values in `weights` as relative probabilities.
	///
	/// Equivalent to calling ``random(weights:using:)`` with the system random number generator.
	///
	/// ### Examples
	///
	/// The following code has a 25% chance of returning `0` and a 75% chance of returning `1`:
	/// ```swift
	///random([0.25, 0.75])
	/// ```
	///
	/// The weight values don't have to add up to `1`. For example, the following code has a 25% chance of returning `0`, a 25% chance of returning `1`, and a 50% chance of returning `2`:
	/// ```swift
	///random([1, 1, 2])
	/// ```
	static func random<W: RandomAccessCollection>(weights: W) -> Int where W.Index == Int, W.Element: BinaryFloatingPoint, W.Element.RawSignificand: FixedWidthInteger {
		var generator = SystemRandomNumberGenerator()
		return random(weights: weights, using: &generator)
	}
}

public extension Collection {
	/// Returns a random element from the collection, weighted by the specified probability value, using the given generator as a source for randomness.
	///
	/// - SeeAlso: ``Swift/Int/random(weights:)`` for an explanation of weight values.
	///
	/// - Parameters:
	///   - weight: A `KeyPath` to the relative weight value of each element in the collection being chosen.
	///   - generator: The RandomNumberGenerator instance to use.
	/// - Returns: An element of the collection chosen at random using the given weights.
	func randomElement<W: BinaryFloatingPoint, R: RandomNumberGenerator>(weight: KeyPath<Self.Element, W>, using generator: inout R) -> Self.Element? where W.RawSignificand: FixedWidthInteger {
		guard !isEmpty else { return nil }
		
		let indices = Array(indices)
		let weights = indices.map { self[$0][keyPath: weight] }
		let random = Int.random(weights: weights, using: &generator)
		return self[indices[random]]
	}
	
	/// Returns a random element from the collection, weighted by the specified probability value, using the values in `weights` as relative probabilities.
	///
	/// Equivalent to calling ``randomElement(weight:using:)`` with the system random number generator.
	///
	/// - SeeAlso: ``Swift/Int/random(weights:)`` for an explanation of weight values.
	///
	/// - Parameters:
	///   - weight: A `KeyPath` to the relative weight value of each element in the collection being chosen.
	/// - Returns: An element of the collection chosen at random using the given weights.
	func randomElement<W: BinaryFloatingPoint>(weight: KeyPath<Self.Element, W>) -> Self.Element? where W.RawSignificand: FixedWidthInteger {
		var generator = SystemRandomNumberGenerator()
		return randomElement(weight: weight, using: &generator)
	}
}

public extension Collection {
	/// Return up to a certain number of random elements from the collection, with the relative chance of sampling each one determined by the provided key path, using the given generator as a source for randomness.
	///
	/// - SeeAlso: ``Swift/Int/random(weights:)`` for an explanation of weight values.
	///
	/// - Parameters:
	///   - sampleCount: The number of samples to return. If greater than or equal to the number of elements in the collection, returns the entire collection.
	///   - weight: A `KeyPath` to the relative weight value of each element in the collection being chosen.
	///   - generator: The RandomNumberGenerator instance to use.
	/// - Returns: Array of `sampleCount` elements from the collection using the given weight values as the relative chance of choosing each element.
	func randomSample<W: BinaryFloatingPoint, R: RandomNumberGenerator>(count sampleCount: Int, weight: KeyPath<Self.Element, W>, using generator: inout R) -> [Self.Element] where Self.Index: Hashable, W.RawSignificand: FixedWidthInteger {
		guard sampleCount < count else { return .init(self) }
		
		var remainingIndicesAndWeights: OrderedDictionary<Index, W> = indices.reduce(into: [:], { result, next in
			result[next] = self[next][keyPath: weight]
		})
		
		var result: [Self.Element] = []
		result.reserveCapacity(sampleCount)
		
		repeat {
			guard let (index, _) = remainingIndicesAndWeights.map({ ($0.key, $0.value) }).randomElement(weight: \.1, using: &generator) else { return result }
			remainingIndicesAndWeights.removeValue(forKey: index)
			result.append(self[index])
		} while result.count < sampleCount
		return result
	}
	
	/// Return up to a certain number of random elements from the collection, with the relative chance of sampling each one determined by the provided key path.
	///
	/// Equivalent to calling ``randomSample(count:weight:using:)`` with the system random number generator.
	///
	/// - SeeAlso: ``Swift/Int/random(weights:)`` for an explanation of weight values.
	///
	/// - Parameters:
	///   - sampleCount: The number of samples to return. If greater than or equal to the number of elements in the collection, returns the entire collection.
	///   - weight: A `KeyPath` to the relative weight value of each element in the collection being chosen.
	/// - Returns: Array of `sampleCount` elements from the collection using the given weight values as the relative chance of choosing each element.
	func randomSample<W: BinaryFloatingPoint>(count sampleCount: Int, weight: KeyPath<Self.Element, W>) -> [Self.Element] where Self.Index: Hashable, W.RawSignificand: FixedWidthInteger {
		var generator = SystemRandomNumberGenerator()
		return randomSample(count: sampleCount, weight: weight, using: &generator)
	}
}
