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

struct AnimatedRadialChart: View, Animatable {
  var name: String
  var time: Double
  var temperature: Double
  var amountWater: Double
  var amountTea: Double
  var rating: Double

  var animatableData: AnimatablePair<
    AnimatablePair<Double, Double>,
    AnimatablePair<
      Double,
      AnimatablePair<Double, Double>
    >
  > {
    get {
      AnimatablePair(
        AnimatablePair(
          time,
          temperature
        ),
        AnimatablePair(
          amountWater,
          AnimatablePair(
            amountTea,
            rating
          )
        )
      )
    }
    set {
      time = newValue.first.first
      temperature = newValue.first.second
      amountWater = newValue.second.first
      amountTea = newValue.second.second.first
      rating = newValue.second.second.second
    }
  }

  var values: [Double] {
    [time, temperature, amountWater, amountTea, rating]
  }

  var lineColors: [Color] {
    [.black, .red, .blue, .green, .yellow]
  }

  var gradientColors: AngularGradient {
    var loopedColors = Array(lineColors)
    loopedColors.append(.black)
    return AngularGradient(
      colors: loopedColors,
      center: .center,
      angle: .degrees(-90)
    )
  }

  var body: some View {
    ZStack {
      GeometryReader { proxy in
        let graphSize = min(proxy.size.width, proxy.size.height) / 2.0
        let xCenter = proxy.size.width / 2.0
        let yCenter = proxy.size.height / 2.0
        ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { val in
          Path { path in
            path.addArc(
              center: .zero,
              radius: graphSize * val,
              startAngle: .degrees(0),
              endAngle: .degrees(360),
              clockwise: true
            )
          }
          .stroke(.gray, lineWidth: 1)
          .offset(x: xCenter, y: yCenter)
        }
        ForEach(values.indices, id: \.self) { index in
          Path { path in
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: graphSize, y: 0))
          }
          .stroke(.gray, lineWidth: 1)
          .offset(x: xCenter, y: yCenter)
          .rotationEffect(.degrees(72.0 * Double(index) - 90.0))
        }
        Path { path in
          var xZero = 0.0
          var yZero = 0.0
          for index in values.indices {
            let value = Double(values[index])
            let angleRadians = (72.0 * Double(-index) - 180.0) * Double.pi / 180.0
            let x = sin(angleRadians) * graphSize * value
            let y = cos(angleRadians) * graphSize * value
            if index == 0 {
              xZero = x
              yZero = y
              path.move(to: .init(x: x, y: y))
            } else {
              path.addLine(to: .init(x: x, y: y))
            }
          }
          path.addLine(to: .init(x: xZero, y: yZero))
        }
        .offset(x: xCenter, y: yCenter)
        .fill(gradientColors)
        .opacity(0.5)
        ForEach(values.indices, id: \.self) { index in
          Path { path in
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: graphSize * values[index], y: 0))
          }
          .stroke(lineColors[index], lineWidth: 2)
          .offset(x: xCenter, y: yCenter)
          .rotationEffect(.degrees(72.0 * Double(index) - 90.0))
        }
      }
    }
  }
}

struct AnimatedRadialChart_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      AnimatedRadialChart(
        name: BrewResult.sampleResult.name,
        time: Double(BrewResult.sampleResult.time) / 600.0,
        temperature: Double(BrewResult.sampleResult.temperature) / 212.0,
        amountWater: BrewResult.sampleResult.amountWarer / 16.0,
        amountTea: BrewResult.sampleResult.amountTea / 16.0,
        rating: Double(BrewResult.sampleResult.rating) / 5.0
      )
      .frame(width: 300, height: 300)
    }
  }
}
