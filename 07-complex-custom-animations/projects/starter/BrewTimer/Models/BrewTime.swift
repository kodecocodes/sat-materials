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

struct BrewTime: Identifiable {
  var id = UUID()
  var timerName: String
  var waterAmount: Double
  var teaAmount: Double
  var temperature: Int
  var timerLength: Int
  var evaluation: [BrewResult]

  static var baseTimers: [BrewTime] {
    var timers: [BrewTime] = .init()

    timers.append(
      BrewTime(
        timerName: "Black Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 200,
        timerLength: 240,
        evaluation: [BrewResult]()
      )
    )
    var brew = BrewTime(
      timerName: "Green Tea",
      waterAmount: 8,
      teaAmount: 2,
      temperature: 175,
      timerLength: 90,
      evaluation: [BrewResult]()
    )
    brew.evaluation.append(
      BrewResult(
        name: "Green Tea",
        time: 90,
        temperature: 175,
        amountWater: 8,
        amountTea: 2,
        rating: 4
      )
    )
    brew.evaluation.append(
      BrewResult(
        name: "Green Tea",
        time: 90,
        temperature: 175,
        amountWater: 16,
        amountTea: 4,
        rating: 4
      )
    )
    timers.append(brew)
    timers.append(
      BrewTime(
        timerName: "Herbal Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 208,
        timerLength: 300,
        evaluation: [BrewResult]()
      )
    )
    var ooBrew = BrewTime(
      timerName: "Oolong Tea",
      waterAmount: 8,
      teaAmount: 2,
      temperature: 195,
      timerLength: 150,
      evaluation: [BrewResult]()
    )
    ooBrew.evaluation.append(contentsOf: BrewTime.previewObjectEvals.evaluation)
    timers.append(ooBrew)
    timers.append(
      BrewTime(
        timerName: "White Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 175,
        timerLength: 150,
        evaluation: [BrewResult]()
      )
    )

    return timers
  }
}

extension BrewTime: Hashable {
  static func == (lhs: BrewTime, rhs: BrewTime) -> Bool {
    return lhs.timerName == rhs.timerName && lhs.temperature == rhs.temperature && lhs.timerLength == rhs.timerLength
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(timerName)
    hasher.combine(waterAmount)
    hasher.combine(teaAmount)
    hasher.combine(temperature)
    hasher.combine(timerLength)
  }
}

extension BrewTime {
  static var previewObject: BrewTime {
    return BrewTime(
      timerName: "Test",
      waterAmount: 6,
      teaAmount: 2,
      temperature: 100,
      timerLength: 5,
      evaluation: [BrewResult]()
    )
  }

  static var previewObjectEvals: BrewTime {
    var brew = BrewTime(
      timerName: "Test",
      waterAmount: 12,
      teaAmount: 4,
      temperature: 200,
      timerLength: 120,
      evaluation: [BrewResult]()
    )

    brew.evaluation.append(
      BrewResult(
        name: "Oolong Tea",
        time: 90,
        temperature: 200,
        amountWater: 12,
        amountTea: 4,
        rating: 3
      )
    )

    brew.evaluation.append(
      BrewResult(
        name: "Oolong Tea",
        time: 120,
        temperature: 190,
        amountWater: 16,
        amountTea: 6,
        rating: 5
      )
    )

    brew.evaluation.append(
      BrewResult(
        name: "Oolong Tea",
        time: 120,
        temperature: 200,
        amountWater: 14,
        amountTea: 6,
        rating: 4
      )
    )

    return brew
  }
}
