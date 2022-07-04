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
    switch pullToRefresh.state {
    case .ongoing, .preparingToFinish:
      JumpingBallView(pullToRefresh: $pullToRefresh)
    case .idle:
      EmptyView()
    default:
      RollingBallView(pullToRefresh: $pullToRefresh)
    }
  }
}

struct RollingBallView: View {
  @Binding var pullToRefresh: PullToRefresh
  @State private var rollOutOffset: CGFloat = 0
  @State private var rollOutRotation: CGFloat = 0

  private let bezierCurve: Animation = .timingCurve(0.24, 1.4, 1, -1, duration: 1)
  
  private let shadowHeight: CGFloat = 5

  var body: some View {
    let initialOffset = -UIScreen.halfWidth - ballSize / 2
    let finalOffset = -initialOffset
    let rollInOffset = initialOffset + (pullToRefresh.progress * finalOffset)
    let rollInRotation = pullToRefresh.progress * .pi * 4
    ZStack {
      Ellipse()
        .fill(Color.gray.opacity(0.4))
        .frame(width: ballSize * 0.8, height: shadowHeight)
        .offset(y: -ballSpacing - shadowHeight / 2)
      
      Ball()
      // when the ball rolls in the rotation depends on the user's gesture progress
      // when rolling out the ball makes two full rotations in a second
        .rotationEffect(Angle(radians: pullToRefresh.state == .finishing ? rollOutRotation : rollInRotation), anchor: .center)
      // Moving from the left corner to the center of the screen
      // when the refreshing starts, then moving out of the screen to the right
        .offset(y: -ballSize / 2 - ballSpacing)
        .onAppear { animateRollingOut() }
    }.offset(x: pullToRefresh.state == .finishing ? rollOutOffset : rollInOffset)
    // the ball slightly bounces during the user's swipe
    .animation(bezierCurve, value: pullToRefresh.progress)
  }

  private func animateRollingOut() {
    guard pullToRefresh.state == .finishing else {
      return
    }
    withAnimation(.easeIn(duration: timeForTheBallToRollOut)) {
      rollOutOffset = UIScreen.main.bounds.width
    }
    withAnimation(.linear(duration: timeForTheBallToRollOut)) {
      rollOutRotation = .pi * 4
    }
  }
}

struct JumpingBallView: View {
  @Binding var pullToRefresh: PullToRefresh
  @State private var isAnimating = false
  @State private var rotation: CGFloat = 0
  @State private var scale: CGFloat = 1

  private let jumpDuration = 0.35
  private let shadowHeight = ballSize / 2

  var body: some View {
    ZStack {
      Ellipse()
        .fill(Color.gray.opacity(pullToRefresh.state == .ongoing ? 0.4 : 0))
        .frame(width: ballSize, height: shadowHeight)
        .scaleEffect(isAnimating ? 1.2 : 0.3, anchor: .center)
        .offset(y: maxOffset - shadowHeight / 2 - ballSpacing)
        .opacity(isAnimating ? 1 : 0.3)

      Ball()
        .rotationEffect(Angle(degrees: rotation), anchor: .center)
        .scaleEffect(x: 1.0 / scale, y: scale, anchor: .bottom)
        .offset(y: isAnimating && pullToRefresh.state == .ongoing ? maxOffset - ballSize / 2 - ballSpacing : -ballSize / 2 - ballSpacing)
        .animation(.easeInOut(duration: timeForTheBallToReturn), value: pullToRefresh.state)
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
      scale = 0.85
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

private let ballSpacing: CGFloat = 8
