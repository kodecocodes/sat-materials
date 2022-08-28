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

import SwiftUI
import Combine

enum TimerStatus {
  case stopped
  case running
  case paused
  case done
}

class TimerManager: ObservableObject {
  public var timerLength: Int
  @Published var startTime: Date?
  @Published var remaingTimeAsString: String
  @Published var remaingTime: Date
  @Published var active = false
  @Published var paused = false
  @Published var digits: [Int]
  @Published var status: TimerStatus = .stopped
  private var originalTime: Int?
  private var activeTimer: Timer?
  private let zeroTime = Calendar.current.date(from: DateComponents(second: 0))

  func start() {
    if status == .paused {
      let componentsLeft = Calendar.current.dateComponents([.minute, .second], from: remaingTime)
      let secondsLeft = (componentsLeft.minute ?? 0) * 60 + (componentsLeft.second ?? originalTime ?? 0)
      let startTimeAgo = (originalTime ?? 0) - secondsLeft
      startTime = Calendar.current.date(byAdding: .second, value: -startTimeAgo, to: .now)
    } else {
      startTime = .now
    }

    status = .running
    activeTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
      self.updateTimes()
      if self.remaingTime == self.zeroTime {
        self.stop()
        self.status = .done
      }
    }
    active = true
    paused = false
  }

  func stop() {
    status = .stopped
    startTime = nil
    activeTimer?.invalidate()
    activeTimer = nil
    active = false
    paused = false
    if let originalTime {
      timerLength = originalTime
      updateTimes()
    }
  }

  func togglePause() {
    status = .paused
    startTime = nil
    activeTimer?.invalidate()
    activeTimer = nil
    active = false
    paused = true
  }

  func setTime(length: Int) {
    originalTime = length
    timerLength = length
    updateTimes()
  }

  func updateTimes() {
    withAnimation {
      remaingTime = amountOfTimeLeft()
      remaingTimeAsString = timeLeftAsString()
      digits = getTimeDigits()
    }
  }

  // swiftlint:disable force_unwrapping

  func timeLeftAsString() -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.second, .minute]

    guard let startTime else {
      let now = Date.now
      let timerLength = Calendar.current.date(
        byAdding: .second,
        value: timerLength,
        to: now
      )!
      return formatter.string(from: now, to: timerLength) ?? "--"
    }

    let endTime = Calendar.current.date(
      byAdding: .second,
      value: timerLength,
      to: startTime
    )!
    return formatter.string(from: .now, to: endTime) ?? "--"
  }

  func getTimeDigits() -> [Int] {
    let timeComponents = Calendar.current.dateComponents([.minute, .second], from: amountOfTimeLeft())
    let minute = timeComponents.minute ?? 0
    let seconds = timeComponents.second ?? 0
    var digitArray: [Int] = []
    digitArray.append(minute / 10)
    digitArray.append(minute % 10)
    digitArray.append(seconds / 10)
    digitArray.append(seconds % 10)

    return digitArray
  }

  func amountOfTimeLeft() -> Date {
    guard let startTime else {
      let now = Date.now
      let timerEnd = Calendar.current.date(
        byAdding: .second,
        value: timerLength,
        to: now
      )!
      let length = Calendar.current.dateComponents([.minute, .second], from: now, to: timerEnd)
      let time = DateComponents(minute: length.minute, second: length.second)
      return Calendar.current.date(from: time)!
    }

    let endTime = Calendar.current.date(
      byAdding: .second,
      value: timerLength,
      to: startTime
    )!
    let length = Calendar.current.dateComponents([.minute, .second], from: .now, to: endTime)
    return Calendar.current.date(from: length)!
  }

  init(length: Int) {
    self.timerLength = length
    self.remaingTime = .now
    self.remaingTimeAsString = ""
    self.digits = []
    self.remaingTime = amountOfTimeLeft()
    self.remaingTimeAsString = timeLeftAsString()
    self.digits = getTimeDigits()
  }
}
