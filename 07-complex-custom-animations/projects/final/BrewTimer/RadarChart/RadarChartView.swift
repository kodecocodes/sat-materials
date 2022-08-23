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

struct RadarChartView: View {
  var data: [GraphDataPoint]

  func degToRadians(_ value: Double) -> Double {
    Double.pi * value / 180.0
  }

  func sinDeg(_ value: Double) -> Double {
    sin(degToRadians(value))
  }

  func cosDeg(_ value: Double) -> Double {
    cos(degToRadians(value))
  }

  var body: some View {
    GeometryReader { proxy in
      let angle = 360.0 / Double(data.count)
      let fullWidth = proxy.size.width / 2.0
      let viewHeight = proxy.size.height / 2.0

      ZStack {
        // Web Lines
        WebLineView(data: data, width: fullWidth, height: viewHeight)
        
        // Values Fill
        GraphFillView(data: data, width: fullWidth, height: viewHeight)
        
        // Data Points
        ForEach(data) { dataPoint in
          let ratio = dataPoint.value / dataPoint.maxValue
          // Scale
          Path { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: fullWidth, y: 0.0))
          }
          .offset(x: fullWidth, y: viewHeight)
          .stroke(.gray, lineWidth: 1.0)
          .rotationEffect(.degrees(Double(dataPoint.id) * angle - 90))
          
          // Value
          Path { path in
            path.move(to: .zero)
            path.addLine(to: .init(x: fullWidth * ratio, y: 0.0))
          }
          .offset(x: fullWidth, y: viewHeight)
          .stroke(dataPoint.color, lineWidth: 2.0)
          .rotationEffect(.degrees(Double(dataPoint.id) * angle - 90))
        }
      }
    }
    .padding()
  }
}

struct RadarChartView_Previews: PreviewProvider {
  static var previews: some View {
    let data = [
      GraphDataPoint(id: 0, value: 5, maxValue: 25, color: .red),
      GraphDataPoint(id: 1, value: 10, maxValue: 25, color: .blue),
      GraphDataPoint(id: 2, value: 15, maxValue: 25, color: .orange),
      GraphDataPoint(id: 3, value: 20, maxValue: 25, color: .green),
      GraphDataPoint(id: 4, value: 20, maxValue: 25, color: .yellow)
    ]
    RadarChartView(data: data)
  }
}
