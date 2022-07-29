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

  // Challenge: Step 3 - Create a custom transition with the RollOutModifier
  var rollOutTransition: AnyTransition {
    AnyTransition.modifier(
      active: RollOutModifier(pullToRefresh: $pullToRefresh, active: true),
      identity: RollOutModifier(pullToRefresh: $pullToRefresh, active: false)
    )
  }

  var body: some View {
    switch pullToRefresh.state {
    case .ongoing, .preparingToFinish:
      JumpingBallView(pullToRefresh: $pullToRefresh)
    case .idle:
      EmptyView()
      // Challenge: Step 4 - Attach the transition in case the state is .finishing
    case .finishing:
      RollingBallView(pullToRefresh: $pullToRefresh)
        .transition(AnyTransition.asymmetric(insertion: .scale, removal: rollOutTransition))
    default:
      RollingBallView(pullToRefresh: $pullToRefresh)
    }
  }
}

// Challenge: Step 1 - Adapt the RollingBallView to receive the rollOutOffset and rollOutRotation as arguments.
// Remove animate() method, as the animation will be triggered from the outside
struct RollingBallView: View {
  @Binding var pullToRefresh: PullToRefresh
  var rollOutOffset: CGFloat?
  var rollOutRotation: CGFloat?

  private let bezierCurve: Animation = .timingCurve(0.24, 1.4, 1, -1, duration: 1)
  private let shadowHeight: CGFloat = 5

  private let initialOffset = -UIScreen.halfWidth - ballSize / 2

  var body: some View {
    let rollInOffset = initialOffset + (pullToRefresh.progress * -initialOffset)
    let rollInRotation = pullToRefresh.progress * .pi * 4

    ZStack {
      Ellipse()
        .fill(Color.gray.opacity(0.4))
        .frame(width: ballSize * 0.8, height: shadowHeight)
        .offset(y: -ballSpacing - shadowHeight / 2)

      Ball()
      // when the ball rolls in the rotation depends on the user's gesture progress
      // when rolling out the ball makes two full rotations in a second
        .rotationEffect(Angle(radians: rollOutRotation ?? rollInRotation), anchor: .center)
      // Moving from the left corner to the center of the screen
      // when the refreshing starts, then moving out of the screen to the right
        .offset(y: -ballSize / 2 - ballSpacing)
    }.offset(x: rollOutOffset ?? rollInOffset)
    // the ball slightly bounces during the user's swipe
    .animation(bezierCurve, value: pullToRefresh.progress)
  }
}

// Challenge: Step 2 - Implement a ViewModifier. As you need to pass properties to the initializer
// instead of simply applying the transformations, you need to restrict the body to type RollingBallView.
struct RollOutModifier: ViewModifier {
  @Binding var pullToRefresh: PullToRefresh
  var active: Bool

  func body(content: Content) -> RollingBallView {
    RollingBallView(
      pullToRefresh: $pullToRefresh,
      rollOutOffset: active ? UIScreen.main.bounds.width : 0,
      rollOutRotation: active ? .pi * 4 : 0
    )
  }

  typealias Body = RollingBallView
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
