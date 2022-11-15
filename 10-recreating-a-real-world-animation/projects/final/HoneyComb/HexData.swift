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

struct HexData: Hashable {
  var hex: Hex
  var center: CGPoint
  var topic: String

  func hash(into hasher: inout Hasher) {
    hasher.combine(topic)
  }

  static func hexes(for topics: [String]) -> [Self] {
    var ringIndex = 0
    var currentHex = Hex(q: 0, r: 0)
    var hexes = [Hex(q: 0, r: 0)]
    let directions = Hex.Direction.allCases.enumerated()

    repeat {
      directions.forEach { index, direction in
        for _ in 0..<(index == 1 ? ringIndex : ringIndex + 1) {
          guard hexes.count != topics.count else { break }
          currentHex = currentHex + direction.hex
          hexes.append(currentHex)
        }
      }

      ringIndex += 1
    } while hexes.count < topics.count

    return hexes.enumerated().map { index, hex in
      HexData(
        hex: hex,
        center: hex.center(),
        topic: topics[index]
      )
    }
  }

  static func hexes(
    from source: Hex,
    _ array: [HexData],
    topics: [String]
  ) -> [HexData] {

    var newHexData: [HexData] = []

    for direction in Hex.Direction.allCases {
      let newHex = source.neighbor(at: direction)

      if !array.contains(where: { $0.hex == newHex }) {
        newHexData.append(HexData(
          hex: newHex,
          center: newHex.center(),
          topic: topics[newHexData.count]
        ))
      }

      if newHexData.count == topics.count {
        return newHexData
      }
    }

    newHexData.append(contentsOf: hexes(
      from: source.neighbor(at: Hex.Direction.allCases.randomElement()!),
      array + newHexData,
      topics: Array(topics.dropFirst(newHexData.count))
    ))

    return newHexData
  }
}
