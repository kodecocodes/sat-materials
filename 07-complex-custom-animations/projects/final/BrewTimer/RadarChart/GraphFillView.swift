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

struct GraphFillView: View {
  var data: [GraphDataPoint]
  var width: Double
  var height: Double

  func degToRadians(_ value: Double) -> Double {
    Double.pi * value / 180.0
  }

  func sinDeg(_ value: Double) -> Double {
    sin(degToRadians(value))
  }

  func cosDeg(_ value: Double) -> Double {
    cos(degToRadians(value))
  }

  var colorArray: [Color] {
    var colors = data.map { $0.color }
    let firstColor = data.first?.color ?? .black
    colors.append(firstColor)
    return colors
  }

  var body: some View {
    var xZero = 0.0
    var yZero = 0.0

    let gradient = AngularGradient(
      colors: colorArray,
      center: .center,
      angle: .degrees(0)
    )

    ZStack {
      Path { path in
        for dataPoint in data {
          let ratio = dataPoint.value / dataPoint.maxValue
          let angle = 360.0 / Double(data.count)
          
          let x = sinDeg(Double(dataPoint.id) * -angle + 90) * ratio * width
          let y = cosDeg(Double(dataPoint.id) * -angle + 90) * ratio * width
          if dataPoint.id == 0 {
            xZero = x
            yZero = y
            path.move(to: .init(x: x, y: y))
          } else {
            path.addLine(to: .init(x: x, y: y))
          }
        }
        path.addLine(to: .init(x: xZero, y: yZero))
      }
      .offset(x: width, y: height)
      .fill(gradient.opacity(0.4))
      .rotationEffect(.degrees(-90))
    }
  }
}

struct GraphFillView_Previews: PreviewProvider {
    static var previews: some View {
      let data = [
        GraphDataPoint(id: 0, value: 5, maxValue: 25, color: .red),
        GraphDataPoint(id: 1, value: 10, maxValue: 25, color: .blue),
        GraphDataPoint(id: 2, value: 15, maxValue: 25, color: .orange),
        GraphDataPoint(id: 3, value: 20, maxValue: 25, color: .green),
        GraphDataPoint(id: 4, value: 20, maxValue: 25, color: .yellow)
      ]

      GraphFillView(data: data, width: 200, height: 200)
    }
}
