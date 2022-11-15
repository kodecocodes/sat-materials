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

struct TimerView: View {
  @StateObject var timerManager = TimerManager(length: 0)
  @State var brewTimer: BrewTime
  @State var showDone: BrewTime?
  @State var amountOfWater = 0.0
  @State var animateTimer = false
  @State var animatePause = false

  let backGroundGradient = LinearGradient(
    colors: [Color("BlackRussian"), Color("DarkOliveGreen"), Color("OliveGreen")],
    startPoint: .init(x: 0.75, y: 0),
    endPoint: .init(x: 0.25, y: 1)
  )

  var timerBorderColor: Color {
    switch timerManager.status {
    case .stopped:
      return Color.red
    case .running:
      return Color.blue
    case .done:
      return Color.green
    case .paused:
      return Color.gray
    }
  }

  var animationGradient: AngularGradient {
    AngularGradient(
      colors: [
        Color("BlackRussian"), Color("DarkOliveGreen"), Color("OliveGreen"),
        Color("DarkOliveGreen"), Color("BlackRussian")
      ],
      center: .center,
      angle: .degrees(animateTimer ? 360 : 0)
    )
  }

  var body: some View {
    NavigationStack {
      VStack {
        BrewInfoView(brewTimer: brewTimer, amountOfWater: $amountOfWater)
        CountingTimerView(timerManager: timerManager)
          .frame(maxWidth: .infinity)
          .overlay {
            switch timerManager.status {
            case .running:
              RoundedRectangle(cornerRadius: 20)
                .stroke(animationGradient, lineWidth: 10)
            case .paused:
              RoundedRectangle(cornerRadius: 20)
                .stroke(.blue, lineWidth: 10)
                .opacity(animatePause ? 0.2 : 1.0)
            default:
              RoundedRectangle(cornerRadius: 20)
                .stroke(timerBorderColor, lineWidth: 5)
            }
          }
          .padding(15)
          .background(
            RoundedRectangle(cornerRadius: 20)
              .fill(
                Color("QuarterSpanishWhite")
              )
          )
          .padding([.leading, .trailing], 5)
          .padding([.top], 15)
        Spacer()
      }
      .padding()
      .background {
        backGroundGradient
          .ignoresSafeArea()
      }
    }
    .onAppear {
      timerManager.setTime(length: brewTimer.timerLength)
      amountOfWater = brewTimer.waterAmount
    }
    .navigationTitle("\(brewTimer.timerName) Timer")
    .toolbarColorScheme(.dark, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .font(.largeTitle)
    .onChange(of: timerManager.status) { newStatus in
      switch newStatus {
      case .done:
        showDone = brewTimer
      case .running:
        animatePause = false
        withAnimation(
          .linear(duration: 1.0)
            .repeatForever(autoreverses: false)
        ) {
          animateTimer = true
        }
      case .paused:
        animateTimer = false
        withAnimation(
          .easeInOut(duration: 0.5)
          .repeatForever()
        ) {
          animatePause = true
        }
      default:
        animateTimer = false
        animatePause = false
      }
    }
    .sheet(item: $showDone) { timer in
      TimerComplete(timer: timer)
    }
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TimerView(
        brewTimer: BrewTime.previewObject
      )
    }
  }
}
