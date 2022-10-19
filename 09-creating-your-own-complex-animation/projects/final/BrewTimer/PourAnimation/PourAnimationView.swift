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

struct PourAnimationView: View {
  @State var shapeTop = 900.0
  @State var wavePhase = 90.0
  @State var wavePhase2 = 0.0
  @State var showPour = true

  let fillColor = Color(red: 0.180, green: 0.533, blue: 0.78)
  let waveColor2 = Color(red: 0.129, green: 0.345, blue: 0.659)

  var waveHeight: Double {
    min(shapeTop / 10.0, 20.0)
  }

  var body: some View {
    ZStack {
      if showPour {
        PourSceneView()
      }
      WaveShape(
        waveTop: shapeTop,
        amplitude: waveHeight * 1.2,
        wavelength: 5,
        phase: wavePhase2
      )
      .fill(waveColor2)
      WaveShape(
        waveTop: shapeTop,
        amplitude: waveHeight,
        wavelength: 4,
        phase: wavePhase
      )
      .fill(fillColor)
    }
    .onAppear {
      withAnimation(
        .easeInOut(duration: 0.5)
        .repeatForever()
      ) {
        wavePhase = -90.0
      }
      withAnimation(
        .easeInOut(duration: 0.3)
        .repeatForever()
      ) {
        wavePhase2 = 270.0
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        withAnimation(.linear(duration: 6.0)) {
          shapeTop = 0.0
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
        showPour = false
      }
    }
  }
}

struct PourAnimationView_Previews: PreviewProvider {
  static var previews: some View {
    PourAnimationView()
  }
}
