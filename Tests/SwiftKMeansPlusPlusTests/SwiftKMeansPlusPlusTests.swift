import Testing
@testable import SwiftKMeansPlusPlus

@Test func testKMeansClustersDeterminism() async throws {
	
	// Generate a collection of SIMD4 with random values
	var gen = SeedableLinearCongruentialRandomNumberGenerator(seed: .init())
	var collection: Array<SIMD4<Float>> = .init()
	collection.reserveCapacity(100)
	for _ in 0..<100 {
		collection.append(SIMD4(.random(in: 0...1, using: &gen), .random(in: 0...1, using: &gen), .random(in: 0...1, using: &gen), .random(in: 0...1, using: &gen)))
	}
	
	// For 100 runs, run the clustering algorithm twice with the same RNG seed and compare the results
	for i in 0...100 {
		var clusterGen1 = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(UInt64(i)))
		let clusters1 = collection.kMeansClusters(upTo: 5, convergeDistance: 0.01, using: &clusterGen1)
		let centers1 = clusters1.map { $0.center }
		
		var clusterGen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(UInt64(i)))
		let clusters2 = collection.kMeansClusters(upTo: 5, convergeDistance: 0.01, using: &clusterGen2)
		let centers2 = clusters2.map { $0.center }
		
		#expect(centers1 == centers2)
	}
}
