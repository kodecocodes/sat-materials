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

struct AnalogTimerView: View {
  @Binding var timerFinished: Bool
  var timer: BrewTime
  @State var timerLength = 0.0
  @State var timeLeft: Int?
  @State var status: TimerStatus = .stopped
  @State var timerEndTime: Date?

  func timeLeftAt(_ current: Date) -> Int {
    switch status {
    case .stopped:
      return Int(timerLength)
    case .running:
      guard let timerEndTime else {
        return Int(timerLength)
      }
      let dateCompenents = Calendar.current.dateComponents([.second], from: current, to: timerEndTime)
      let remainingTime = dateCompenents.second ?? Int(timerLength)
      if remainingTime <= 0 {
        DispatchQueue.main.async {
          status = .stopped
          self.timerEndTime = nil
          timerFinished = true
        }
      }
      return remainingTime
    case .paused:
      return timeLeft ?? Int(timerLength)
    case .done:
      return 0
    }
  }

  func decimalTimeLeftAt(_ current: Date) -> Double {
    switch status {
    case .stopped:
      return timerLength
    case .running:
      guard let timerEndTime else {
        return timerLength
      }

      let timerDifference = Calendar.current.dateComponents([.second, .nanosecond], from: current, to: timerEndTime)
      let seconds = Double(timerDifference.second ?? Int(timerLength))
      let nanoSeconds = Double(timerDifference.nanosecond ?? 0) / 1e9
      let remainingTime = seconds + nanoSeconds
      if remainingTime <= 0 {
        DispatchQueue.main.async {
          status = .stopped
          self.timerEndTime = nil
          timerFinished = true
        }
      }
      return remainingTime
    case .paused:
      return Double(timeLeft ?? Int(timerLength))
    case .done:
      return 0
    }
  }

  func timeLeftString(_ time: Int) -> String {
    let minutes = time / 60
    let seconds = time % 60

    return "\(minutes) m \(seconds) s"
  }

  func drawBorder(context: GraphicsContext, size: Int) {
    // 1
    let timerSize = CGSize(width: size, height: size)
    // 2
    let outerPath = Path(
      ellipseIn: CGRect(origin: .zero, size: timerSize)
    )
    // 3
    context.stroke(
      outerPath,
      with: .color(.black),
      lineWidth: 3
    )
  }

  func drawMinutes(context: GraphicsContext, size: Int) {
    // 1
    let center = Double(size / 2)

    // 2
    for minute in 0..<10 {
      // 3
      let minuteAngle = Double(minute) / 10 * 360.0
      // 4
      var minuteTickPath = Path()
      minuteTickPath.move(to: .init(x: center, y: 0))
      minuteTickPath.addLine(to: .init(x: center * 0.9, y: 0))
      // 4
      var tickContext = context
      // 6
      tickContext.rotate(by: .degrees(-minuteAngle))
      // 7
      tickContext.stroke(
        minuteTickPath,
        with: .color(.black)
      )

      // 1
      let minuteString = "\(minute)"
      let textSize = minuteString.calculateTextSizeFor(
        font: UIFont.preferredFont(forTextStyle: .title2)
      )
      // 2
      let textRect = CGRect(origin: .init(x: -textSize.width / 2.0, y: -textSize.height / 2.0), size: .zero)
      // 3
      let minuteAngleRadians = (minuteAngle - 90) * Double.pi / 180.0
      // 4
      let xShift = sin(-minuteAngleRadians) * center * 0.8
      let yShift = cos(-minuteAngleRadians) * center * 0.8
      // 5
      var stringContext = context
      stringContext.translateBy(x: xShift, y: yShift)
      stringContext.rotate(by: .degrees(90))
      // 6
      let resolvedText = stringContext.resolve(
        Text(minuteString).font(.title2)
      )
      // 7
      stringContext.draw(resolvedText, in: textRect)
    }
  }

  func createHandPath(
    length: Double,
    crossDistance: Double,
    middleDistance: Double,
    endDistance: Double,
    width: Double
  ) -> Path {
    // 1
    let halfWidth = width / 2.0

    // 2
    var path = Path()
    path.move(to: .zero)
    // 3
    path.addCurve(
      to: .init(x: length * crossDistance, y: 0),
      control1: .init(x: length * crossDistance, y: length * -halfWidth),
      control2: .init(x: length * crossDistance, y: length * -halfWidth)
    )
    path.addCurve(
      to: .init(x: length * endDistance, y: 0),
      control1: .init(x: length * middleDistance, y: length * halfWidth),
      control2: .init(x: length * middleDistance, y: length * halfWidth)
    )
    path.addCurve(
      to: .init(x: length * crossDistance, y: 0),
      control1: .init(x: length * middleDistance, y: length * -halfWidth),
      control2: .init(x: length * middleDistance, y: length * -halfWidth)
    )
    path.addCurve(
      to: .zero,
      control1: .init(x: length * crossDistance, y: length * halfWidth),
      control2: .init(x: length * crossDistance, y: length * halfWidth)
    )

    return path
  }

  func drawHands(context: GraphicsContext, size: Int, remainingTime: Double) {
    // 1
    let length = Double(size / 2)
    // 2
    let secondsLeft = remainingTime.truncatingRemainder(dividingBy: 60.0)
    let secondAngle = secondsLeft / 60.0 * 360.0
    // 3
    let minuteColor = Color("DarkOliveGreen")
    let secondColor = Color("BlackRussian")

    // 4
    let secondHandPath = createHandPath(
      length: length,
      crossDistance: 0.4,
      middleDistance: 0.6,
      endDistance: 0.7,
      width: 0.07
    )
    var secondContext = context
    secondContext.rotate(by: .degrees(secondAngle))
    secondContext.fill(
      secondHandPath,
      with: .color(secondColor)
    )
    secondContext.stroke(
      secondHandPath,
      with: .color(secondColor),
      lineWidth: 3
    )

    // 1
    let minutesLeft = remainingTime / 60.0
    let minuteAngle = minutesLeft / 10.0 * 360.0
    // 2
    let minuteHandPath = createHandPath(
      length: length,
      crossDistance: 0.3,
      middleDistance: 0.5,
      endDistance: 0.6,
      width: 0.1
    )
    // 3
    var minuteContext = context
    minuteContext.rotate(by: .degrees(minuteAngle))
    minuteContext.fill(
      minuteHandPath,
      with: .color(minuteColor)
    )
    minuteContext.stroke(
      minuteHandPath,
      with: .color(minuteColor),
      lineWidth: 5
    )
  }

  var body: some View {
    VStack {
      // 1
      Slider(value: $timerLength, in: 0...600, step: 15)
      // 2
      TimerControlView(
        timerLength: timerLength,
        timeLeft: $timeLeft,
        status: $status,
        timerEndTime: $timerEndTime,
        timerFinished: $timerFinished
      )
      .font(.title)
      // 1
      ZStack {
        // 2
        Canvas { gContext, size in
          // 3
          let timerSize = Int(min(size.width, size.height) * 0.95)
          // 4
          let xOffset = (size.width - Double(timerSize)) / 2.0
          // 5
          let yOffset = (size.height - Double(timerSize)) / 2.0
          // 6
          gContext.translateBy(x: xOffset, y: yOffset)
          drawBorder(context: gContext, size: timerSize)
          gContext.translateBy(x: Double(timerSize / 2), y: Double(timerSize / 2))
          gContext.rotate(by: .degrees(-90))
          drawMinutes(context: gContext, size: timerSize)
        }
        // 1
        TimelineView(
          .animation(minimumInterval: 0.1, paused: status != .running)
        ) { timeContext in
          // 2
          Canvas { gContext, size in
            // 3
            let timerSize = Int(min(size.width, size.height))
            gContext.translateBy(x: size.width / 2, y: size.height / 2)
            gContext.rotate(by: .degrees(-90))
            let remainingSeconds = decimalTimeLeftAt(timeContext.date)
            drawHands(context: gContext, size: timerSize, remainingTime: remainingSeconds)
          }
        }
      }
      .padding()
    }
    .onAppear {
      // 3
      timerLength = Double(timer.timerLength)
    }
  }
}

struct AnalogTimerView_Previews: PreviewProvider {
  static var previews: some View {
    AnalogTimerView(
      timerFinished: .constant(false),
      timer: BrewTime.previewObjectEvals
    )
  }
}
