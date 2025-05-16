//
//  Test.swift
//  SwiftKMeansPlusPlus
//
//  Created by Dale Price on 5/16/25.
//

import Testing

/// Tests the determinism of the seedable RNG that the other tests depend on
struct SeedableRNGDeterminismTests {

    @Test func testSeedableRNGDeterminism() async throws {
		var seed0gen = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(0))
		let seed0genValues = [
			Float.random(in: 0.0...1.0, using: &seed0gen),
			Float.random(in: 0.0...1.0, using: &seed0gen),
			Float.random(in: 0.0...1.0, using: &seed0gen),
			Float.random(in: 0.0...1.0, using: &seed0gen),
			Float.random(in: 0.0...1.0, using: &seed0gen),
			Float.random(in: 0.0...1.0, using: &seed0gen),
		]
		
		var seed0gen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(0))
		let seed0gen2Values = [
			Float.random(in: 0.0...1.0, using: &seed0gen2),
			Float.random(in: 0.0...1.0, using: &seed0gen2),
			Float.random(in: 0.0...1.0, using: &seed0gen2),
			Float.random(in: 0.0...1.0, using: &seed0gen2),
			Float.random(in: 0.0...1.0, using: &seed0gen2),
			Float.random(in: 0.0...1.0, using: &seed0gen2),
		]
		
		var seed1gen = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(1))
		let seed1genValues = [
			Float.random(in: 0.0...1.0, using: &seed1gen),
			Float.random(in: 0.0...1.0, using: &seed1gen),
			Float.random(in: 0.0...1.0, using: &seed1gen),
			Float.random(in: 0.0...1.0, using: &seed1gen),
			Float.random(in: 0.0...1.0, using: &seed1gen),
			Float.random(in: 0.0...1.0, using: &seed1gen),
		]
		
		var seed1gen2 = SeedableLinearCongruentialRandomNumberGenerator(seed: .init(1))
		let seed1gen2Values = [
			Float.random(in: 0.0...1.0, using: &seed1gen2),
			Float.random(in: 0.0...1.0, using: &seed1gen2),
			Float.random(in: 0.0...1.0, using: &seed1gen2),
			Float.random(in: 0.0...1.0, using: &seed1gen2),
			Float.random(in: 0.0...1.0, using: &seed1gen2),
			Float.random(in: 0.0...1.0, using: &seed1gen2),
		]
		
		for index in seed0genValues.indices {
			#expect(seed0genValues[index] == seed0gen2Values[index])
			#expect(seed1genValues[index] == seed1gen2Values[index])
			
			#expect(seed0genValues[index] != seed1genValues[index])
		}
    }

}
