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
  @ObservedObject var timerManager = TimerManager(length: 0)
  @State var brewTimer: BrewTime
  @State var showDone: BrewTime?
  @State var amountOfWater = 0.0
  @State var animateTimer = 0.0

  var teaToUse: Double {
    let tspPerOz = brewTimer.teaAmount / brewTimer.waterAmount
    return tspPerOz * amountOfWater
  }
  var timerBorderColor: Color {
    switch timerManager.status {
    case .stopped:
      return Color.gray
    case .running:
      return Color.blue
    case .done:
      return Color.green
    }
  }

  var animationGradient: AngularGradient {
    AngularGradient(
      colors: [.blue, Color(red: 0.67, green: 0.85, blue: 0.90), .blue],
      center: .center,
      angle: .degrees(animateTimer * 360.0)
    )
  }

  struct HeadingText: ViewModifier {
    func body(content: Content) -> some View {
      return content
        .font(.title.bold())
    }
  }

  struct InformationText: ViewModifier {
    func body(content: Content) -> some View {
      return content
        .font(.title2)
        .padding(.bottom, 15)
    }
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 5) {
        Text("Brewing Temperature")
          .modifier(HeadingText())
        Text("\(brewTimer.temperature) °F")
          .modifier(InformationText())
        Text("Water Amount")
          .modifier(HeadingText())
        Text("\(amountOfWater.formatted()) ounces")
          .modifier(InformationText())
        Slider(value: $amountOfWater, in: 0...24, step: 0.1)
        Text("Amount of Tea to Use")
          .modifier(HeadingText())
        Text("\(teaToUse.formatted()) teaspoons")
          .modifier(InformationText())
      }
      CountingTimerView(timerManager: timerManager)
        .frame(maxWidth: .infinity)
        .overlay {
          if timerManager.status == .running {
            RoundedRectangle(cornerRadius: 20)
              .stroke(animationGradient, lineWidth: 10)
          } else {
            RoundedRectangle(cornerRadius: 20)
              .stroke(timerBorderColor, lineWidth: 5)
          }
        }
        .padding([.leading, .trailing], 5)
      Spacer()
    }
    .padding()
    .onAppear {
      timerManager.setTime(length: brewTimer.timerLength)
      amountOfWater = brewTimer.waterAmount
    }
    .navigationTitle("\(brewTimer.timerName) Timer")
    .font(.largeTitle)
    .onChange(of: timerManager.status) { newStatus in
      if newStatus == .done {
        showDone = brewTimer
      }
      // 1
      if newStatus == .running {
        // 2
        withAnimation(
          // 3
          .linear(duration: 1.0)
          // 4
          .repeatForever(autoreverses: false)
        ) {
          // 5
          animateTimer = 1.0
        }
      }
    }
    .sheet(item: $showDone) { timer in
      TimerComplete(timer: timer)
    }
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    TimerView(
      brewTimer: BrewTime.previewObject
    )
  }
}
