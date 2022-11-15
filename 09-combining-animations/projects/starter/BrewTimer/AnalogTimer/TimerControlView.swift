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

import SwiftUI

struct TimerControlView: View {
  var timerLength: Double
  @Binding var timeLeft: Int?
  @Binding var status: TimerStatus
  @Binding var timerEndTime: Date?
  @Binding var timerFinished: Bool

  func startTimer() {
    if status == .paused {
      guard let timeLeft else { return }
      print("Time Left \(timeLeft)")
      timerEndTime = Calendar.current.date(byAdding: .second, value: timeLeft, to: Date())
      status = .running
    } else {
      let endTime = Calendar.current.date(byAdding: .second, value: Int(timerLength), to: Date())
      timerEndTime = endTime
      status = .running
    }
  }

  func pauseTimer() {
    guard let endTime = timerEndTime else { return }
    let dateComponents = Calendar.current.dateComponents([.second], from: Date(), to: endTime)
    timeLeft = dateComponents.second ?? Int(timerLength)
    timerEndTime = nil
    status = .paused
  }

  func stopTimer() {
    status = .stopped
    timerEndTime = nil
  }

  var body: some View {
    HStack {
      Button {
        stopTimer()
      } label: {
        Image(systemName: "stop.fill")
          .tint(.red)
      }
      .disabled(status != .running && status != .paused)
      Spacer()
        .frame(width: 30)
      Button {
        pauseTimer()
      } label: {
        Image(systemName: "pause.fill")
      }
      .disabled(status != .running)
      Spacer()
        .frame(width: 30)
      Button {
        startTimer()
      } label: {
        Image(systemName: "play.fill")
          .tint(.green)
      }
      .disabled(status == .running)
    }
  }
}

struct TimerControlView_Previews: PreviewProvider {
  static var previews: some View {
    TimerControlView(
      timerLength: 120,
      timeLeft: .constant(10),
      status: .constant(.stopped),
      timerEndTime: .constant(nil),
      timerFinished: .constant(false)
    )
    .font(.title)
  }
}
