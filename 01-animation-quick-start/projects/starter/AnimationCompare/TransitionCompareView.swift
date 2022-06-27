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

enum TransitionType {
  case slide
  case scale
  case move
  case offset
}

struct TransitionCompareView: View {
  @State var showSquare = true
  @State var insertTransition = TransitionType.slide
  @State var removalTransition = TransitionType.slide
  var demoTransition: AnyTransition {
    let insert = transitionForType(insertTransition)
    let removal = transitionForType(removalTransition)
    return .asymmetric(insertion: insert, removal: removal)
  }

  func transitionForType(_ transition: TransitionType) -> AnyTransition {
    switch transition {
    case .slide:
      return AnyTransition.slide
    case .scale:
      return AnyTransition.scale
    case .move:
      return AnyTransition.move(edge: .top)
    case .offset:
      return AnyTransition.offset()
    }
  }

  var body: some View {
    VStack {
      HStack {
        Text("Insertion Transition")
        Picker("Transition", selection: $insertTransition) {
          Text("Slide").tag(TransitionType.slide)
          Text("Scale").tag(TransitionType.scale)
          Text("Move Leading").tag(TransitionType.move)
          Text("Scale Top Trailing").tag(TransitionType.scale)
          Text("Offset").tag(TransitionType.offset)
        }.pickerStyle(.menu)
      }
      HStack {
        Text("Removal Transition")
        Picker("Transition", selection: $removalTransition) {
          Text("Slide").tag(TransitionType.slide)
          Text("Scale").tag(TransitionType.scale)
          Text("Move Leading").tag(TransitionType.move)
          Text("Scale Top Trailing").tag(TransitionType.scale)
          Text("Offset").tag(TransitionType.offset)
        }.pickerStyle(.menu)
      }
      if showSquare {
        Button("Hide the Square") {
          withAnimation {
            showSquare = false
          }
        }.transition(.move(edge: .leading))
      } else {
        Button("Show the Square") {
          withAnimation {
            showSquare = true
          }
        }
        .transition(.move(edge: .trailing))
      }
      if showSquare {
        RoundedRectangle(cornerRadius: 15)
          .transition(demoTransition)
          .frame(width: 125, height: 125)
          .foregroundColor(.red)
          .frame(height: 150)
          .onTapGesture {
            withAnimation {
              showSquare = false
            }
          }
      }
      Spacer()
    }
  }
}

struct TransitionCompareView_Previews: PreviewProvider {
  static var previews: some View {
    TransitionCompareView()
  }
}
