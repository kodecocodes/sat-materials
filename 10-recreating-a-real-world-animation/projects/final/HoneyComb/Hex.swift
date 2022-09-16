//
//  Hex.swift
//  HoneyComb
//
//  Created by Irina Galata on 02.09.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
struct Hex: Equatable {
  let q, r, s: Int

  static let directions = [
    Hex(q: 1, r: 0),
    Hex(q: 0, r: 1),
    Hex(q: -1, r: 1),
    Hex(q: -1, r: 0),
    Hex(q: 0, r: -1),
    Hex(q: 1, r: -1)
  ]

  init(q: Int, r: Int, s: Int) {
    self.q = q
    self.r = r
    self.s = s
  }

  init(q: Int, r: Int) {
    self.init(q: q, r: r, s: -q - r)
  }

  static func == (lhs: Hex, rhs: Hex) -> Bool {
    return lhs.q == rhs.q && lhs.r == rhs.r
  }

  func add(hex: Hex) -> Hex {
    return Hex(q: q + hex.q, r: r + hex.r)
  }

  func neigbouring(hex: Hex) -> Bool {
    for index in (0..<6) where neighbor(at: index) == hex {
      return true
    }
    return false
  }

  func neighbor(at index: Int) -> Hex {
    return add(hex: Hex.directions[index])
  }
}
// swiftlint:enable identifier_name
