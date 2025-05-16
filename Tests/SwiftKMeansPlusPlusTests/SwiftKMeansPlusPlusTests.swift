import Testing
@testable import SwiftKMeansPlusPlus

struct DeterminismTests {
	
	/// For 1000 seeds, test whether the first 1000 results are identical using that seed
	@Test func testWeightedRandomDeterminism() async throws {
		for seed in 0...1000 {
			var gen1 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(seed))
			var gen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(seed))
			
			for _ in 0...1000 {
				let result1 = Int.random(weights: [0.25, 0.75, 0.1], using: &gen1)
				
				let result2 = Int.random(weights: [0.25, 0.75, 0.1], using: &gen2)
				
				#expect(result1 == result2)
			}
		}
	}
	
	@Test func testRandomElementDeterminism() async throws {
		var sampleFrom: Array<Float> = []
		sampleFrom.reserveCapacity(100)
		for _ in 0..<100 {
			sampleFrom.append(.random(in: 0...1))
		}
		
		for seed in 0..<100 {
			var gen1 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(seed))
			var gen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(seed))
			
			for _ in 0..<100 {
				let element1 = sampleFrom.randomElement(weight: \.self, using: &gen1)
				let element2 = sampleFrom.randomElement(weight: \.self, using: &gen2)
				
				#expect(element1 == element2)
			}
		}
	}
	
	@Test func testRandomSampleDeterminism() async throws {
		var sampleFrom: Array<Float> = []
		sampleFrom.reserveCapacity(100)
		for _ in 0..<100 {
			sampleFrom.append(.random(in: 0...1))
		}
		
		for seed in 0..<100 {
			var gen1 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(seed))
			var gen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(seed))
			
			for _ in 0..<10 {
				let sample1 = sampleFrom.randomSample(count: 10, weight: \.self, using: &gen1)
				let sample2 = sampleFrom.randomSample(count: 10, weight: \.self, using: &gen2)
				
				#expect(sample1 == sample2)
			}
		}
	}
	
	@Test func testClusterCentersDeterminism() async throws {
		// Generate a collection of SIMD4 with random values
		var gen = SeedableLinearCongruentialRandomNumberGenerator(seed: .init())
		var collection: Array<SIMD4<Float>> = .init()
		collection.reserveCapacity(100)
		for _ in 0..<100 {
			collection.append(SIMD4(.random(in: 0...1, using: &gen), .random(in: 0...1, using: &gen), .random(in: 0...1, using: &gen), .random(in: 0...1, using: &gen)))
		}
		
		for i in 0...100 {
			var clusterGen1 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(i))
			let centers1 = collection.initialClusterCenters(upTo: 5, using: &clusterGen1)
			
			var clusterGen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(UInt64(i)))
			let centers2 = collection.initialClusterCenters(upTo: 5, using: &clusterGen2)
			
			#expect(centers1 == centers2)
		}
	}
	
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
			var clusterGen1 = SeedableLinearCongruentialRandomNumberGenerator(seed: UInt64(i))
			let clusters1 = collection.kMeansClusters(upTo: 5, convergeDistance: 0.01, using: &clusterGen1)
			let centers1 = clusters1.map { $0.center }
			
			var clusterGen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(UInt64(i)))
			let clusters2 = collection.kMeansClusters(upTo: 5, convergeDistance: 0.01, using: &clusterGen2)
			let centers2 = clusters2.map { $0.center }
			
			#expect(centers1 == centers2)
		}
	}
	
}
