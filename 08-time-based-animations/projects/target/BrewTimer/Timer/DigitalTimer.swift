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

struct DigitalTimer: View {
  var timer: BrewTime
  var timerManager = TimerManager(length: 0)

  var body: some View {
    VStack {
      HStack {
        Button {
          timerManager.stop()
        } label: {
          Image(systemName: "stop.fill")
            .tint(.red)
        }
        //.disabled(!timerManager.active && !timerManager.paused)
        Spacer()
          .frame(width: 30)
        Button {
          timerManager.togglePause()
        } label: {
          Image(systemName: "pause.fill")
        }
        //.disabled(timerManager.paused || !timerManager.active)
        Spacer()
          .frame(width: 30)
        Button {
          timerManager.start()
        } label: {
          Image(systemName: "play.fill")
            .tint(.green)
        }
        //.disabled(timerManager.active)
      }
      .font(.title)
      TimelineView(.animation) { timeContext in
        Canvas { context, size in
          let clockSize = Int(min(size.width, size.height))
          drawBorder(context: context, size: clockSize)
          drawTimerTickMarks(context: context, size: clockSize, length: timer.timerLength)
          drawNumbers(context: context, size: clockSize, length: timer.timerLength)
          drawTimeRemaining(context: context, size: clockSize, timerDate: timeContext.date)
        }
      }
      .onAppear {
        timerManager.setTime(length: timer.timerLength)
      }
    }
    .padding()
  }

  // Outside border
  func drawBorder(context: GraphicsContext, size: Int) {
    let clockSize = CGSize(width: size, height: size)
    let outerPath = Path(
      ellipseIn: CGRect(origin: .zero, size: clockSize)
    )
    context.stroke(
      outerPath,
      with: .color(.black),
      lineWidth: 3
    )
  }

  func drawTimerTickMarks(context: GraphicsContext, size: Int, length: Int) {
    let center = size / 2
    let minutes = length / 60

    for tickNumber in 0..<minutes * 4 {
      let minuteAngle = Double(tickNumber * 15) / Double(timer.timerLength) * 360.0 - 90.0
      let lineRatio = tickNumber % 4 == 0 ? 0.15 : 0.075
      var tickPath = Path()
      tickPath.move(to: .init(x: CGFloat(center), y: 0))
      tickPath.addLine(to: .init(x: CGFloat(center) - lineRatio * CGFloat(center), y: 0))
      var tickContext = context
      tickContext.translateBy(x: CGFloat(center), y: CGFloat(center))
      tickContext.rotate(by: .degrees(minuteAngle))
      tickContext.stroke(
        tickPath,
        with: .color(.black),
        lineWidth: 2
      )
    }
  }

  func drawNumbers(context: GraphicsContext, size: Int, length: Int) {
    let minutes = length / 60
    let center = CGFloat(size / 2)

    for minute in 0..<minutes {
      let angle = Double(minute * 60) / Double(length) * 360.0
      let minuteString = "\(minute)"
      let textSize = (minuteString as NSString).size(
        withAttributes: [.font: UIFont.preferredFont(forTextStyle: .title1)]
      )
      let textRect = CGRect(origin: .init(x: -textSize.width / 2.0, y: -textSize.height / 2.0), size: .zero)
      let angleRadians = (angle - 180) * Double.pi / 180.0
      let xLoc = sin(angleRadians) * center * 0.7
      let yLoc = cos(angleRadians) * center * 0.7
      var minuteContext = context
      minuteContext.translateBy(x: xLoc + center, y: yLoc + center)
      let resolvedText = context.resolve(
        Text("\(minute)").font(.title)
      )
      minuteContext.draw(
        resolvedText,
        in: textRect
      )
    }
  }

  func drawTimeRemaining(context: GraphicsContext, size: Int, timerDate: Date) {
    let center = CGFloat(size / 2)
    let timeLeft = timerManager.amountOfTimeLeft()
    let dateComponents = Calendar.current.dateComponents([.minute, .second], from: timeLeft)
    let minutesLeft = dateComponents.minute ?? 0
    let secondsLeft = dateComponents.second ?? 0
    let totalSecondsLeft = minutesLeft * 60 + secondsLeft

    let fractionTimeLeft = Double(totalSecondsLeft) / Double(timerManager.timerLength)
    let minuteAngle = fractionTimeLeft * 360.0 - 90.0

    if let timerStartTime = timerManager.startTime {
      var secondPath = Path()
      secondPath.move(to: .zero)
      secondPath.addCurve(
        to: .init(x: center * 0.4, y: 0),
        control1: .init(x: center * 0.4, y: center * -0.03),
        control2: .init(x: center * 0.4, y: center * -0.03)
      )
      secondPath.addCurve(
        to: .init(x: center * 0.7, y: 0),
        control1: .init(x: center * 0.6, y: center * 0.03),
        control2: .init(x: center * 0.6, y: center * 0.03)
      )
      secondPath.addCurve(
        to: .init(x: center * 0.4, y: 0),
        control1: .init(x: center * 0.6, y: center * -0.03),
        control2: .init(x: center * 0.6, y: center * -0.03)
      )
      secondPath.addCurve(
        to: .zero,
        control1: .init(x: center * 0.4, y: center * 0.03),
        control2: .init(x: center * 0.4, y: center * 0.03)
      )

      let fSec = Calendar.current.dateComponents([.second, .nanosecond], from: timerStartTime, to: timerDate)

      let secondHandAmount = fSec.second ?? 0
      let nanoSecondHandAmount = fSec.nanosecond ?? 0
      let secondCount = Double(secondHandAmount) + Double(nanoSecondHandAmount) / 1e9
      let secondAngle = Double(-secondCount) / 60.0 * 360.0 - 90.0
      var secondLineContext = context
      secondLineContext.translateBy(x: center, y: center)
      secondLineContext.rotate(by: .degrees(secondAngle))
      secondLineContext.fill(
        secondPath,
        with: .color(.blue))
      secondLineContext.stroke(
        secondPath,
        with: .color(.blue),
        lineWidth: 5
      )
    }

    var path = Path()
    path.move(to: .zero)
    path.addCurve(
      to: .init(x: center * 0.4, y: 0),
      control1: .init(x: center * 0.3, y: center * -0.05),
      control2: .init(x: center * 0.3, y: center * -0.05)
    )
    path.addCurve(
      to: .init(x: center * 0.6, y: 0),
      control1: .init(x: center * 0.5, y: center * 0.05),
      control2: .init(x: center * 0.5, y: center * 0.05)
    )
    path.addCurve(
      to: .init(x: center * 0.4, y: 0),
      control1: .init(x: center * 0.5, y: center * -0.05),
      control2: .init(x: center * 0.5, y: center * -0.05)
    )
    path.addCurve(
      to: .zero,
      control1: .init(x: center * 0.3, y: center * 0.05),
      control2: .init(x: center * 0.3, y: center * 0.05)
    )

    var minuteLineContext = context
    minuteLineContext.translateBy(x: center, y: center)
    minuteLineContext.rotate(by: .degrees(minuteAngle))
    minuteLineContext.fill(
      path,
      with: .color(.black)
    )
    minuteLineContext.stroke(
      path,
      with: .color(.black),
      lineWidth: 5
    )
  }
}

struct DigitalTimer_Previews: PreviewProvider {
  static var previews: some View {
    DigitalTimer(
      timer: BrewTime.previewObjectEvals,
      timerManager: TimerManager(length: BrewTime.previewObjectEvals.timerLength)
    )
  }
}
