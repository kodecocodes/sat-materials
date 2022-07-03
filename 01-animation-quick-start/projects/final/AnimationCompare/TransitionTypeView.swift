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

struct TransitionTypeView: View {
  @Binding var selectionType: TransitionType
  @Binding var transitionProperties: TransitionProperties

  var body: some View {
    Picker("Transition", selection: $selectionType) {
      Text("Move").tag(TransitionType.move)
      Text("Offset").tag(TransitionType.offset)
      Text("Opacity").tag(TransitionType.opacity)
      Text("Scale").tag(TransitionType.scale)
      Text("Slide").tag(TransitionType.slide)
    }
    if selectionType == .scale {
      Stepper(
        "Scale \(transitionProperties.scale.formatted())",
        value: $transitionProperties.scale,
        in: 0...3.0,
        step: 0.1
      )
      Picker("Anchor", selection: $transitionProperties.anchorPoint) {
        Text("Top Leading").tag(UnitPoint.topLeading)
        Text("Top").tag(UnitPoint.top)
        Text("Top Trailing").tag(UnitPoint.topTrailing)
        Text("Leading").tag(UnitPoint.leading)
        Text("Center").tag(UnitPoint.center)
        Text("Trailing").tag(UnitPoint.trailing)
        Text("Bottom Leading").tag(UnitPoint.bottomLeading)
        Text("Bottom").tag(UnitPoint.bottom)
        Text("Bottom Trailing").tag(UnitPoint.bottomTrailing)
      }
    }
    if selectionType == .offset {
      Stepper(
        "Offset X: \(transitionProperties.offsetX.formatted())",
        value: $transitionProperties.offsetX,
        in: -260...260,
        step: 20
      )
      Stepper(
        "Offset Y: \(transitionProperties.offsetY.formatted())",
        value: $transitionProperties.offsetY,
        in: -250...250,
        step: 20
      )
    }
    if selectionType == .move {
      Picker("Edge", selection: $transitionProperties.edge) {
        Text("Top").tag(Edge.top)
        Text("Bottom").tag(Edge.bottom)
        Text("Leading").tag(Edge.leading)
        Text("Trailing").tag(Edge.trailing)
      }
    }
  }
}

struct TransitionTypeView_Previews: PreviewProvider {
  static var previews: some View {
    TransitionTypeView(
      selectionType: .constant(.scale),
      transitionProperties: .constant(TransitionProperties()))
  }
}
