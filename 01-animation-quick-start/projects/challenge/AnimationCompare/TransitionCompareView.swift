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

struct TransitionCompareView: View {
  @State var showSquare = true
  @State var useOneTransition = false
  @State var insertSelection = TransitionType.opacity
  @State var insertProperties = TransitionProperties()
  @State var removalSelection = TransitionType.opacity
  @State var removalProperties = TransitionProperties()

  func transitionForType(_ transition: TransitionType, properties: TransitionProperties) -> AnyTransition {
    switch transition {
    case .opacity:
      return AnyTransition.opacity
    case .slide:
      return AnyTransition.slide
    case .scale:
      return AnyTransition.scale(
        scale: properties.scale, anchor: properties.anchorPoint
      )
    case .move:
      return AnyTransition.move(edge: properties.edge)
    case .offset:
      return AnyTransition.offset(
        x: properties.offsetX, y: properties.offsetY
      )
    }
  }

  var squareTransition: AnyTransition {
    if useOneTransition {
      return transitionForType(insertSelection, properties: insertProperties)
    }
    let insertTransition = transitionForType(
      insertSelection, properties: insertProperties
    )
    let removeTransition = transitionForType(
      removalSelection, properties: removalProperties
    )
    return AnyTransition.asymmetric(
      insertion: insertTransition,
      removal: removeTransition
    )
  }

  var body: some View {
    VStack {
      VStack {
        Button(showSquare ? "Hide the Square" : "Show the Square") {
          withAnimation {
            showSquare.toggle()
          }
        }
        if showSquare {
          RoundedRectangle(cornerRadius: 15)
            .frame(width: 150, height: 150)
            .foregroundColor(.red)
            .transition(squareTransition)
        }
        Spacer()
      }
      .frame(height: 250)
      Spacer()
      Form {
        Section("Insertion Transition") {
          TransitionTypeView(
            selectionType: $insertSelection,
            transitionProperties: $insertProperties
          )
          Toggle("Use For Both", isOn: $useOneTransition)
        }
        if !useOneTransition {
          Section("Removal Transition") {
            TransitionTypeView(
              selectionType: $removalSelection,
              transitionProperties: $removalProperties
            )
          }
        }
      }
    }
  }
}

struct TransitionCompareView_Previews: PreviewProvider {
  static var previews: some View {
    TransitionCompareView()
  }
}
