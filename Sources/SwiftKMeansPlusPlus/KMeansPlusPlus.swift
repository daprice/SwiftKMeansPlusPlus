//
//  KMeansPlusPlus.swift
//  BlurHashViews
//
//  Created by Dale Price on 7/28/24.
//

import Foundation
import simd

extension Collection where Element: SIMD, Element.Scalar: BinaryFloatingPoint, Element.Scalar.RawSignificand: FixedWidthInteger, Self.Index: Hashable {
	
	/// Returns the mean (average) of all values in the collection.
	public var mean: Element {
		self.reduce(.zero, +) / Element.Scalar(count)
	}
	
	/// A tuple representing a cluster generated by the K-Means algorithm. Contains both the center (mean of all points) and a collection of the points that make up the cluster.
	public typealias Cluster = (
		center: Element,
		points: [Element]
	)
	
	/// Calculate initial cluster centers using the k-Means++ initialization algorithm, using the specified random number generator as a source of randomness.
	///
	/// See https://en.wikipedia.org/wiki/K-means++#Improved_initialization_algorithm for an explanation of this algorithm.
	private func initialClusterCenters<R: RandomNumberGenerator>(upTo maxClusterCount: Int, using generator: inout R) -> [Element] {
		// Start with one center chosen at random
		guard let initialCenterIndex = indices.randomElement(using: &generator) else { return [] }
		var centers = [self[initialCenterIndex]]
		var remainingIndices = Set<Index>(indices).subtracting([initialCenterIndex])
		
		// Until `maxClusterCount` centers are chosen, repeat choosing another center
		repeat {
			// Calculate distance squared between each point and the nearest center that has already been chosen
			let remainingPointIndicesWithDistancesSquared = remainingIndices.reduce(into: [Index: Element.Scalar]()) { result, pointIndex in
				let point = self[pointIndex]
				let distanceSquaredToNearestCenter = centers.map({ distanceSquared(point, $0) }).min()
				result[pointIndex] = distanceSquaredToNearestCenter
			}
			
			// Choose a point at random to be the new center, using squared distance as weighted probability
			guard let weightedRandomPointIndex = remainingPointIndicesWithDistancesSquared.randomElement(weight: \.value, using: &generator) else { return centers }
			
			// Add the chosen point as a new center and remove it from the eligible points to be centers
			centers.append(self[weightedRandomPointIndex.key])
			remainingIndices.remove(weightedRandomPointIndex.key)
		} while centers.count < maxClusterCount
		
		return centers
	}
	
	/// Partition the collection's members into the specified number of clusters using the k-Means algorithm, using the specified random number generator as a source of randomness.
	/// 
	/// See [Wikipedia: k-means++](https://en.wikipedia.org/wiki/K-means++) for an explanation of the algorithm.
	///
	/// - Parameters:
	///   - maxClusterCount: The target number of clusters to divide the collection into. The method will return fewer clusters if the collection contains fewer elements than the desired number of clusters.
	///   - convergeDistance: Keep iterating until the means of each cluster vary by less than this amount between iterations.
	///   - generator: The `RandomNumberGenerator` instance to use as a source of randomness when determining the initial clusters.
	/// - Returns: An array of ``Cluster``, each containing the mean (average) value in each cluster and the collection of points that were sorted into that cluster.
	public func kMeansClusters<R: RandomNumberGenerator>(upTo maxClusterCount: Int, convergeDistance: Element.Scalar, using generator: inout R) -> [Cluster] {
		// Select initial centers according to K-means++
		var centers = initialClusterCenters(upTo: maxClusterCount, using: &generator)
		
		guard !centers.isEmpty else { return [] }
		
		var clusters: [[Element]]
		
		var moveDistanceSquared = Element.Scalar.zero
		
		repeat {
			clusters = .init(repeating: [], count: centers.count)
			
			// sort points into clusters
			for point in self {
				let closestCenterIndex = centers.enumerated().min(by: { distanceSquared($0.element, point) < distanceSquared($1.element, point) })!.offset
				clusters[closestCenterIndex].append(point)
			}
			
			let newCenters = clusters.map(\.mean)
			
			// calculate how far the centers have moved since the last iteration
			moveDistanceSquared = zip(centers, newCenters).reduce(Element.Scalar.zero) {
				$0 + distanceSquared($1.0, $1.1)
			}
			
			centers = newCenters
		} while moveDistanceSquared > convergeDistance * convergeDistance
		
		return centers.enumerated().map { Cluster($0.element, clusters[$0.offset]) }
	}
	
	/// Partition the collection's members into the specified number of clusters using the k-Means algorithm.
	///
	/// See [Wikipedia: k-means++](https://en.wikipedia.org/wiki/K-means++) for an explanation of the algorithm.
	///
	/// Equivalent to calling ``kMeansClusters(upTo:convergeDistance:using:)`` with the system random number generator.
	///
	/// - Parameters:
	///   - maxClusterCount: The target number of clusters to divide the collection into. The method will return fewer clusters if the collection contains fewer elements than the desired number of clusters.
	///   - convergeDistance: Keep iterating until the means of each cluster vary by less than this amount between iterations.
	/// - Returns: An array of ``Cluster``, each containing the mean (average) value in each cluster and the collection of points that were sorted into that cluster.
	public func kMeansClusters(upTo maxClusterCount: Int, convergeDistance: Element.Scalar) -> [Cluster] {
		var generator = SystemRandomNumberGenerator()
		return kMeansClusters(upTo: maxClusterCount, convergeDistance: convergeDistance, using: &generator)
	}
}