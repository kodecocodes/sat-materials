//
//  HexData.swift
//  HoneyComb
//
//  Created by Irina Galata on 04.09.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

let diameter = 125.0

let topics = [
  "Politics", "Science", "Animals",
  "Plants", "Tech", "Music",
  "Sports", "Books", "Cooking",
  "Traveling", "TV-series", "Art",
  "Finance", "Fashion"
]

struct HexData: Hashable {
  var hex: Hex
  var center: CGPoint
  var topic: String

  func hash(into hasher: inout Hasher) {
    hasher.combine(topic)
  }
}

func center(for hex: Hex) -> CGPoint {
  let qVector = CGVector(dx: 3.0 / 2.0, dy: sqrt(3.0) / 2.0)
  let rVector = CGVector(dx: 0.0, dy: sqrt(3.0))
  let size = diameter / sqrt(3.0)
  let x = qVector.dx * Double(hex.q) * size
  let y = (qVector.dy * Double(hex.q) + rVector.dy * Double(hex.r)) * size

  return CGPoint(x: x, y: y)
}

func createHexes(for topics: [String]) -> [HexData] {
  var ringIndex = 0
  var currentHex = Hex(q: 0, r: 0)
  var hexes = [currentHex]
  let directions = Hex.directions.enumerated()
  while hexes.count < topics.count {
    directions.forEach { index, direction in
      for _ in 0..<(index == 1 ? ringIndex : ringIndex + 1) {
        if hexes.count == topics.count { return }
        currentHex = currentHex.add(hex: direction)
        hexes.append(currentHex)
      }
    }

    ringIndex += 1
  }

  return hexes.enumerated().map { index, hex in
    HexData(hex: hex, center: center(for: hex), topic: topics[index])
  }
}

func createHexes(
  from source: Hex,
  _ array: [HexData],
  topics: [String]
) -> [HexData] {
  var newHexData: [HexData] = []

  for index in 0..<6 {
    let newHex = source.neighbor(at: index)

    if !array.contains(where: { $0.hex == newHex }) {
      newHexData.append(HexData(
        hex: newHex,
        center: center(for: newHex),
        topic: topics[newHexData.count]
      ))
    }

    if newHexData.count == topics.count {
      return newHexData
    }
  }

  newHexData.append(contentsOf: createHexes(
    from: source.neighbor(at: Int.random(in: 0..<6)),
    array + newHexData,
    topics: Array(topics.dropFirst(newHexData.count))
  ))

  return newHexData
}
