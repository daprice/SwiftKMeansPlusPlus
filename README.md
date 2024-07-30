# SwiftKMeansPlusPlus

Swift implementation of the *k*-means++ algorithm that can operate on a collection of SIMD vectors of any length.

## Overview

[k-Means](https://en.wikipedia.org/wiki/K-means) is an algorithm for partitioning a collection of points into clusters based on the cluster with the nearest mean value to each point. [k-Means++](https://en.wikipedia.org/wiki/K-means++) is an improved algorithm for choosing the initial cluster centers to avoid suboptimal clustering.
		  
This library contains extensions to `Collection` that perform k-Means++ clustering on SIMD values of any length, which can represent points in Euclidean space, colors in formats like RGB or HSV, or just about anything else.
