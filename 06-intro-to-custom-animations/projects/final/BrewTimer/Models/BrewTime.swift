/// Copyright (c) 2022 Razeware LLC
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

  static var baseTimers: [BrewTime] {
    var timers: [BrewTime] = []
    timers.append(
      BrewTime(
        timerName: "Black Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 200,
        timerLength: 240
      )
    )
    timers.append(
      BrewTime(
        timerName: "Green Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 175,
        timerLength: 90
      )
    )
    timers.append(
      BrewTime(
        timerName: "Herbal Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 208,
        timerLength: 300
      )
    )
    timers.append(
      BrewTime(
        timerName: "Oolong Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 195,
        timerLength: 150
      )
    )
    timers.append(
      BrewTime(
        timerName: "White Tea",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 175,
        timerLength: 150
      )
    )
    timers.append(
      BrewTime(
        timerName: "Test",
        waterAmount: 8,
        teaAmount: 2,
        temperature: 175,
        timerLength: 5
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
      timerLength: 5
    )
  }
}
