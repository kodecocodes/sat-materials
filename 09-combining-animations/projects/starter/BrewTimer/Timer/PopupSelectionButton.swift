/// Copyright (c) 2022 Kodeco Inc.
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

struct PopupSelectionButton: View {
  @Binding var currentValue: Double?
  var values: [Double]
  @State private var showOptions = false
  @State private var animateOptions = false


  func xOffset(_ index: Int) -> Double {
    let distance = 180.0
    let angle = Double(90 + 15 * index) * Double.pi / 180.0
    return distance * sin(angle) - distance
  }

  func yOffset(_ index: Int) -> Double {
    let distance = 180.0
    let angle = Double(90 + 15 * index) * Double.pi / 180.0
    return distance * cos(angle) - 40
  }

  var body: some View {
    ZStack {
      Group {
        if showOptions {
          ForEach(values.indices, id: \.self) { index in
            Text(values[index], format: .number)
              .transition(.scale.animation(.easeOut(duration: 0.25)))
              .modifier(CircledText(backgroundColor: Color("OliveGreen")))
              .offset(
                x: animateOptions ? xOffset(index) : 0,
                y: animateOptions ? yOffset(index) : 0
              )
              .onTapGesture {
                currentValue = values[index]
                withAnimation(.easeOut(duration: 0.25)) {
                  animateOptions = false
                }
                withAnimation {
                  showOptions = false
                }
              }
          }
          Text("\(Image(systemName: "xmark.circle"))")
            .transition(.opacity.animation(.linear(duration: 0.25)))
            .modifier(CircledText(backgroundColor: Color(.red)))
        } else {
          if let value = currentValue {
            Text(value, format: .number)
              .modifier(CircledText(backgroundColor: Color("Bourbon")))
          } else {
            Text("\(Image(systemName: "exclamationmark"))")
              .modifier(CircledText(backgroundColor: Color(.red)))
          }
        }
      }
      .onTapGesture {
        if showOptions {
          withAnimation(.easeOut(duration: 0.25)) {
            animateOptions = false
          }
          withAnimation {
            showOptions = false
          }
        } else {
          withAnimation {
            showOptions = true
          }
          withAnimation(.easeOut(duration: 0.25)) {
            animateOptions = true
          }
        }
      }
    }
  }
}

struct PopupSelectionButton_Previews: PreviewProvider {
  static var previews: some View {
    PopupSelectionButton(
      currentValue: .constant(3),
      values: [1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0]
    )
  }
}
