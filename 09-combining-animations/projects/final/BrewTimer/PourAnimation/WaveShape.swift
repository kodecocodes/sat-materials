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

struct WaveShape: Shape {
  var waveTop: Double = 0.0

  var amplitude = 100.0
  var wavelength = 1.0
  var phase = 0.0

  // 1
  var animatableData: AnimatablePair<
    AnimatablePair<Double, Double>,
    AnimatablePair<Double, Double>
    > {
    get {
      // 2
      AnimatablePair(
        AnimatablePair(waveTop, amplitude),
        AnimatablePair(wavelength, phase)
      )
    }
    set {
      // 3
      waveTop = newValue.first.first
      amplitude = newValue.first.second
      wavelength = newValue.second.first
      phase = newValue.second.second
    }
  }

  func path(in rect: CGRect) -> Path {
    // 1
    Path { path in
      // 2
      for x in 0 ..< Int(rect.width) {
        // 3
        let angle = Double(x) / rect.width * wavelength * 360.0 + phase
        // 4
        let y = sin(Angle(degrees: angle).radians) * amplitude
        // 5
        if x == 0 {
          path.move(to: .init(
            x: Double(x),
            y: waveTop - y
          ))
        } else {
          path.addLine(to: .init(
            x: Double(x),
            y: waveTop - y
          ))
        }
      }

      path.addLine(to: .init(x: rect.width, y: rect.height))
      path.addLine(to: .init(x: 0, y: rect.height))
      path.closeSubpath()
    }
  }
}

struct WaveShape_Previews: PreviewProvider {
  static var previews: some View {
    WaveShape(waveTop: 200.0)
      .fill(.black)
  }
}
