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

struct TimerView: View {
  @State var brewTimer: BrewTime
  @State var showDone: BrewTime?
  @ObservedObject var timerManager = TimerManager(length: 0)
  let zeroTime = Calendar.current.date(from: DateComponents(second: 0))

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 5) {
        Text("Brewing Temperature")
          .font(.title.bold())
        Text("\(brewTimer.temperature) °F")
          .font(.title2)
        Text("Amount")
          .font(.title.bold())
        Text("\(brewTimer.amount) ounces")
          .font(.title2)
      }
      VStack {
        Text(timerManager.remaingTimeAsString)
        HStack {
          Button {
            timerManager.stop()
          } label: {
            Image(systemName: "stop.fill")
          }
          .disabled(!timerManager.active)
          Button {
            timerManager.start()
          } label: {
            Image(systemName: "play.fill")
          }
          .disabled(timerManager.active)
        }
        Spacer()
      }
      .navigationTitle("\(brewTimer.timerName) Timer")
      .font(.largeTitle)
      .onAppear {
        timerManager.setTime(length: brewTimer.timerLength)
      }
      .onChange(of: timerManager.remaingTime) { timeLeft in
        if timeLeft == zeroTime {
          showDone = brewTimer
          timerManager.stop()
        }
      }
      .sheet(item: $showDone) { timer in
        TimerComplete(timer: timer)
      }
    }
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    TimerView(
      brewTimer:
        BrewTime(
          timerName: "Test",
          amount: 6,
          temperature: 100,
          timerLength: 5
        )
    )
  }
}
