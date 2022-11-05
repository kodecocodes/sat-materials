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

struct AnimationView: View {
  var animation: AnimationData
  @Binding var location: Double
  var currentAnimation: Animation {
    switch animation.type {
    case .easeIn:
      return Animation.easeIn(duration: animation.length)
    case .easeOut:
      return Animation.easeOut(duration: animation.length)
    case .easeInOut:
      return Animation.easeInOut(duration: animation.length)
    case .interpolatingSpring:
      return Animation.interpolatingSpring(
        // 1
        mass: animation.mass,
        // 2
        stiffness: animation.stiffness,
        // 3
        damping: animation.damping,
        // 4
        initialVelocity: animation.initialVelocity
      )
    case .spring:
      return Animation.spring(
        response: animation.response,
        dampingFraction: animation.dampingFraction
      )
    default:
      return Animation.linear(duration: animation.length)
    }
  }
  var slowMotion = false

  var body: some View {
    GeometryReader { proxy in
      Group {
        HStack {
          // 1
          Image(systemName: "gear.circle")
            .rotationEffect(.degrees(360 * location))
          Image(systemName: "star.fill")
            // 2
            .offset(x: proxy.size.width * location * 0.8)
        }
        .font(.title)
        // 3
        .animation(
          currentAnimation
            .delay(animation.delay)
            .speed(slowMotion ? 0.25 : 1.0),
          value: location
        )
      }
    }
  }
}

struct AnimationView_Previews: PreviewProvider {
  static var previews: some View {
    let animation = AnimationData(type: .linear, length: 1.0, delay: 0.0)

    AnimationView(
      animation: animation,
      location: .constant(0.0)
    )
  }
}
