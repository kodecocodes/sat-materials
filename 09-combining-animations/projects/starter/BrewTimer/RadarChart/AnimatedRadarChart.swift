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

struct AnimatedRadarChart: View, Animatable {
  var time: Double
  var temperature: Double
  var amountWater: Double
  var amountTea: Double
  var rating: Double

  var animatableData: AnimatablePair<
    AnimatablePair<Double, Double>,
    AnimatablePair<
      AnimatablePair<Double, Double>,
      Double
    >
  > {
    get {
      AnimatablePair(
        AnimatablePair(time, temperature),
        AnimatablePair(
          AnimatablePair(amountWater, amountTea),
          rating
        )
      )
    }
    set {
      time = newValue.first.first
      temperature = newValue.first.second
      amountWater = newValue.second.first.first
      amountTea = newValue.second.first.second
      rating = newValue.second.second
    }
  }

  var values: [Double] {
    [
      time / 600.0,
      temperature / 212.0,
      amountWater / 16.0,
      amountTea / 16.0,
      rating / 5.0
    ]
  }

  let lineColors: [Color] = [.black, .red, .blue, .green, .yellow]

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

        PolygonChartView(
          values: values,
          graphSize: graphSize,
          colorArray: lineColors,
          xCenter: xCenter,
          yCenter: yCenter
        )

        ForEach(values.indices, id: \.self) { index in
          Path { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: 0, y: -graphSize))
          }
          .stroke(.gray, lineWidth: 1)
          .offset(x: xCenter, y: yCenter)
          .rotationEffect(.degrees(72.0 * Double(index)))
          Path { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: 0, y: -graphSize * values[index]))
          }
          .stroke(lineColors[index], lineWidth: 2)
          .offset(x: xCenter, y: yCenter)
          .rotationEffect(.degrees(72.0 * Double(index)))
        }
      }
    }
  }
}

struct AnimatedRadarChart_Previews: PreviewProvider {
  static var previews: some View {
    AnimatedRadarChart(
      time: Double(BrewResult.sampleResult.time),
      temperature: Double(BrewResult.sampleResult.temperature),
      amountWater: BrewResult.sampleResult.amountWater,
      amountTea: BrewResult.sampleResult.amountTea,
      rating: Double(BrewResult.sampleResult.rating)
    )
  }
}

struct PolygonChartView: View {
  var values: [Double]
  var graphSize: Double
  var colorArray: [Color]
  var xCenter: Double
  var yCenter: Double

  var gradientColors: AngularGradient {
    var loopedColors = Array(colorArray)
    loopedColors.append(colorArray.first ?? .black)
    return AngularGradient(
      colors: loopedColors,
      center: .center,
      angle: .degrees(-90)
    )
  }

  var body: some View {
    Path { path in
      for index in values.indices {
        let value = values[index]
        let angleRadians = 72.0 * Double(index) * Double.pi / 180.0
        let x = sin(angleRadians) * graphSize * value
        let y = cos(angleRadians) * -graphSize * value
        if index == 0 {
          path.move(to: .init(x: x, y: y))
        } else {
          path.addLine(to: .init(x: x, y: y))
        }
      }
      path.closeSubpath()
    }
    .offset(x: xCenter, y: yCenter)
    .fill(gradientColors)
    .opacity(0.5)
  }
}
