/// Copyright (c) 2022 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

struct Hex: Equatable {
  let q, r: Int
  var s: Int { -q - r }

  func neighbor(at direction: Direction) -> Hex {
    return self + direction.hex
  }

  func isNeighbor(of hex: Hex) -> Bool {
    Direction.allCases.contains { neighbor(at: $0) == hex }
  }

  func center() -> CGPoint {
    let qVector = CGVector(dx: 3.0 / 2.0, dy: sqrt(3.0) / 2.0)
    let rVector = CGVector(dx: 0.0, dy: sqrt(3.0))
    let size = diameter / sqrt(3.0)
    let x = qVector.dx * Double(q) * size
    let y = (qVector.dy * Double(q) +
             rVector.dy * Double(r)) * size

    return CGPoint(x: x, y: y)
  }
}

extension Hex: AdditiveArithmetic {
  static func - (lhs: Hex, rhs: Hex) -> Hex {
    Hex(
      q: lhs.q - rhs.q,
      r: lhs.r - rhs.r
    )
  }

  static func + (lhs: Hex, rhs: Hex) -> Hex {
    Hex(
      q: lhs.q + rhs.q,
      r: lhs.r + rhs.r
    )
  }

  static var zero: Hex {
    .init(q: 0, r: 0)
  }
}

extension Hex {
  enum Direction: CaseIterable {
    case bottomRight
    case bottom
    case bottomLeft
    case topLeft
    case top
    case topRight

    var hex: Hex {
      switch self {
      case .top:
        return Hex(q: 0, r: -1)
      case .topRight:
        return Hex(q: 1, r: -1)
      case .bottomRight:
        return Hex(q: 1, r: 0)
      case .bottom:
        return Hex(q: 0, r: 1)
      case .bottomLeft:
        return Hex(q: -1, r: 1)
      case .topLeft:
        return Hex(q: -1, r: 0)
      }
    }
  }
}
