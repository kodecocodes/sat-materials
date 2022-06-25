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

struct BallView: View {
  @Binding var pullToRefresh: PullToRefresh

  var body: some View {
    ZStack {
      if pullToRefresh.started && !pullToRefresh.animationFinished {
        JumpingBallView(pullToRefresh: $pullToRefresh)
      } else if pullToRefresh.animationFinished || pullToRefresh.progress > 0 {
        RollingBallView(pullToRefresh: $pullToRefresh)
      } else {
        EmptyView()
      }
    }
  }
}

struct RollingBallView: View {
  @Binding var pullToRefresh: PullToRefresh
  @State private var offset: CGFloat = 0
  @State private var rotation: CGFloat = 0

  private let bezierCurve: Animation = .timingCurve(0.24, 1.4, 1, -1, duration: 1)

  var body: some View {
    let rollInOffset = -UIScreen.halfWidth + (pullToRefresh.progress * UIScreen.halfWidth) - ballSize / 2
    let rollInRotation = pullToRefresh.progress * .pi * 2

    Ball()
      // when the ball rolls in the rotation depends on the user's gesture progress
      // when rolling out the ball makes two full rotations in a second
      .rotationEffect(Angle(radians: pullToRefresh.animationFinished ? rotation : rollInRotation), anchor: .center)
      // the ball slightly bounces during the user's swipe
      .animation(bezierCurve, value: pullToRefresh.progress)
      // Moving from the left corner to the center of the screen
      // when the refreshing starts, then moving out of the screen to the right
      .offset(x: pullToRefresh.animationFinished ? offset : rollInOffset, y: -ballSize / 2 - spacing)
      .onAppear { animate() }
  }

  private func animate() {
    guard pullToRefresh.animationFinished else {
      return
    }
    withAnimation(.easeIn(duration: timeForTheBallToRollOut)) {
      offset = UIScreen.main.bounds.width
    }
    withAnimation(.linear(duration: timeForTheBallToRollOut)) {
      rotation = .pi * 4
    }
  }
}

struct JumpingBallView: View {
  @Binding var pullToRefresh: PullToRefresh
  @State private var isAnimating = false
  @State private var rotation: CGFloat = 0
  @State private var squash: CGFloat = 1

  private let jumpDuration = 0.35

  var body: some View {
    ZStack {
      Ellipse()
        .fill(Color.gray.opacity(pullToRefresh.started ? 0.4 : 0))
        .frame(width: ballSize, height: ballSize / 2)
        .scaleEffect(isAnimating ? 1.2 : 0.3, anchor: .center)
        .offset(y: maxOffset - ballSize / 1.5)
        .opacity(isAnimating ? 1 : 0.3)
        .scaleEffect(pullToRefresh.progress)

      Ball()
        .rotationEffect(Angle(degrees: rotation), anchor: .center)
        .scaleEffect(x: 1.0 / squash, y: squash, anchor: .bottom)
        .offset(y: isAnimating && !pullToRefresh.updateFinished ? maxOffset - ballSize : -ballSize / 2 - spacing)
        .animation(.easeInOut(duration: timeForTheBallToReturn), value: pullToRefresh.updateFinished)
        .onAppear { animate() }
    }
  }

  private func animate() {
    withAnimation(.linear(duration: jumpDuration * 2).repeatForever(autoreverses: false)) {
      rotation = 360
    }
    withAnimation(.easeInOut(duration: jumpDuration).repeatForever()) {
      isAnimating = true
    }
    withAnimation(.easeOut(duration: jumpDuration).repeatForever()) {
      squash = 0.85
    }
  }
}

struct Ball: View {
  var body: some View {
    Image("basketball_ball")
      .resizable()
      .frame(width: ballSize, height: ballSize)
  }
}

extension UIScreen {
  static var halfWidth: CGFloat {
    main.bounds.width / 2
  }
}

private let spacing: CGFloat = 4