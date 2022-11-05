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
  @State var showDone = false
  @State var amountOfWater = 0.0
  @State var animateTimer = true
  @State var animatePause = false
  @State var brewingTemp = 0
  @State var timerLength = 0.0
  @State var sheetResult: BrewResult?

  let backGroundGradient = LinearGradient(
    colors: [Color("BlackRussian"), Color("DarkOliveGreen"), Color("OliveGreen")],
    startPoint: .init(x: 0.75, y: 0),
    endPoint: .init(x: 0.25, y: 1)
  )

  var teaToUse: Double {
    let tspPerOz = brewTimer.teaAmount / brewTimer.waterAmount
    return tspPerOz * amountOfWater
  }

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
      angle: .degrees(animateTimer ? 360.0 : 0.0)
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

  func sheetDismissed() {
    guard let result = sheetResult else { return }
    brewTimer.evaluation.append(result)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        backGroundGradient
          .ignoresSafeArea()
        VStack {
          VStack {
            CountingTimerView(timerManager: timerManager)
              .frame(maxWidth: .infinity)
              .overlay {
                if timerManager.status == .running {
                  RoundedRectangle(cornerRadius: 20)
                    .stroke(animationGradient, lineWidth: 10)
                } else if timerManager.status == .paused {
                  RoundedRectangle(cornerRadius: 20)
                    .stroke(.blue, lineWidth: 10)
                    .opacity(animatePause ? 0.2 : 1.0)
                } else {
                  RoundedRectangle(cornerRadius: 20)
                    .stroke(timerBorderColor, lineWidth: 5)
                }
              }
            Slider(value: $timerLength, in: 0...600, step: 15)
          }
            .padding(15)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(
                  Color("QuarterSpanishWhite")
                )
            )
            .padding([.leading, .trailing], 5)
            .padding([.bottom], 15)
          ScrollView {
            BrewInfoView(brewTimer: brewTimer, amountOfWater: $amountOfWater)
            if !brewTimer.evaluation.isEmpty {
              EvaluationListView(result: brewTimer.evaluation)
            }
          }
        }
        .padding()
      }
    }
    .onAppear {
      timerManager.setTime(length: brewTimer.timerLength)
      timerLength = Double(brewTimer.timerLength)
      amountOfWater = brewTimer.waterAmount
      withAnimation(.easeOut(duration: 1.0)) {
        brewingTemp = brewTimer.temperature
      }
    }
    .navigationTitle("\(brewTimer.timerName) Timer")
    .toolbarColorScheme(.dark, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .font(.largeTitle)
    .onChange(of: timerManager.status) { newStatus in
      if newStatus == .done {
        let newResult = BrewResult(
          name: brewTimer.timerName,
          time: Int(timerLength),
          temperature: brewingTemp,
          amountWater: amountOfWater,
          amountTea: teaToUse,
          rating: 0
        )
        sheetResult = newResult
        showDone = true
      }
      if newStatus == .running {
        animatePause = false
        withAnimation(
          .linear(duration: 1.0)
          .repeatForever(autoreverses: false)
        ) {
          // 5
          animateTimer = true
        }
      }
      if newStatus == .paused {
        animateTimer = false
        withAnimation(
          .easeInOut(duration: 0.5)
          .repeatForever()
        ) {
          animatePause = true
        }
      } else {
        animateTimer = false
        animatePause = false
      }
    }
    .onChange(of: timerLength) { newValue in
      timerManager.setTime(length: Int(newValue))
    }
    .sheet(
      isPresented: $showDone,
      onDismiss: sheetDismissed
    ) {
      TimerComplete(
        brewResult: $sheetResult)
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
